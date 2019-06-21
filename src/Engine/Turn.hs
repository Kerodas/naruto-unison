-- | Turn execution. The surface of the game engine.
module Engine.Turn (run) where

import ClassyPrelude hiding ((\\), groupBy, drop, head)

import Data.List ((\\))
import Data.List.NonEmpty (groupBy, head)

import           Core.Util ((—))
import qualified Class.Labeled as Labeled
import qualified Class.Parity as Parity
import qualified Class.Play as P
import           Class.Play (MonadGame)
import           Class.Random (MonadRandom)
import qualified Class.TurnBased as TurnBased
import qualified Model.Act as Act
import           Model.Act (Act)
import qualified Model.Barrier as Barrier
import qualified Model.Context as Context
import qualified Model.Delay as Delay
import qualified Model.Game as Game
import           Model.Game (Game)
import qualified Model.Ninja as Ninja
import qualified Model.Player as Player
import qualified Model.Status as Status
import           Model.Status (Bomb(..), Status)
import qualified Model.Slot as Slot
import           Model.Slot (Slot)
import qualified Engine.Chakras as Chakras
import qualified Engine.Effects as Effects
import qualified Engine.Execute as Execute
import           Engine.Execute (Affected(..))
import qualified Engine.Traps as Traps
import qualified Engine.Trigger as Trigger

-- | The game engine's main function. 
-- Performs 'Act's and 'Model.Channel.Channel's;
-- applies effects from 'Bomb's, 'Barrier.Barrier's, 'Delay.Delay's, and 
-- 'Model.Trap.Trap's;
-- decrements all 'TurnBased.TurnBased' data;
-- and resolves 'Model.Chakra.Chakras' for the next turn.
run :: ∀ m. (MonadGame m, MonadRandom m) => [Act] -> m ()
run actions = do
    initial     <- P.game
    player      <- Game.playing <$> P.game
    let opponent = Player.opponent player
    traverse_ (Execute.act []) actions
    channels <- concatMap getChannels . filter (Ninja.playing player) .
                Game.ninjas <$> P.game
    traverse_ (Execute.act [Channeled]) channels
    Traps.runTurn initial
    doBombs Remove initial
    P.modify $ Game.alter (Ninja.decrStats <$>)
    doBarriers
    doDelays
    doDeaths
    P.modify \game -> game { Game.delays = decrDelays $ Game.delays game }
    expired <- P.game
    P.modify $ Game.alter (Ninja.decr <$>)
    doBombs Expire expired
    doBombs Done initial
    doHpsOverTime
    P.modify \game -> game { Game.playing = opponent }
    doDeaths
    Chakras.gain
  where
    getChannels n = map (Act.fromChannel n) .
                    filter ((1 /=) . TurnBased.getDur) $
                    Ninja.channels n
    decrDelays = filter ((0 /=) . Delay.dur) . mapMaybe TurnBased.decr

-- | Runs 'Game.delays'.
doDelays :: ∀ m. (MonadGame m, MonadRandom m) => m ()
doDelays = filter ((<= 1) . Delay.dur) . Game.delays <$> P.game >>=
           traverse_ (P.launch . ($ ()) . Delay.effect)

-- | Executes 'Status.bombs' of a 'Status'.
doBomb :: ∀ m. (MonadGame m, MonadRandom m) => Bomb -> Slot -> Status -> m ()
doBomb bomb target st = traverse_ detonate $ Status.bombs st
  where
    ctx = (Context.fromStatus st) { Context.target = target }
    detonate (bomb', f)
      | bomb == bomb' = P.withContext ctx . Execute.wrap [Trapped] $ P.play f
      | otherwise     = return ()

-- | Executes 'Status.bombs' of all 'Status'es that were removed.
doBombs :: ∀ m. (MonadGame m, MonadRandom m) => Bomb -> Game -> m ()
doBombs bomb game = P.game >>= sequence_ . concat . Game.zipNinjasWith comp game
  where
    comp n n' = doBomb bomb (Ninja.slot n) <$>
                Ninja.statuses n \\ Ninja.statuses n'

-- | Executes 'Barrier.while' and 'Barrier.finish' effects.
doBarriers :: ∀ m. (MonadGame m, MonadRandom m) => m ()
doBarriers = do
    player <- P.player
    ninjas <- Game.ninjas <$> P.game
    traverse_ (doBarrier player) $ concatMap collect ninjas
  where
    collect = (head <$>) . groupBy Labeled.eq . sort . Ninja.barrier
    doBarrier p b
      | Barrier.dur b == 1 = P.launch . Barrier.finish b $ Barrier.amount b
      | Parity.allied p $ Barrier.user b = P.launch $ Barrier.while b ()
      | otherwise = return ()

-- | Executes 'Trigger.death'.
doDeaths :: ∀ m. (MonadGame m, MonadRandom m) => m ()
doDeaths = traverse_ Trigger.death Slot.all

-- | Executes 'Model.Effect.Afflict' and 'Model.Effect.Heal' 
-- 'Model.Effect.Effect's.
doHpOverTime :: ∀ m. MonadGame m => Slot -> m ()
doHpOverTime slot = do
    player <- P.player
    n      <- Game.ninja slot <$> P.game
    hp     <- Effects.hp player n <$> P.game
    when (Ninja.alive n) . P.modify . Game.adjust slot $
        Ninja.adjustHealth (— hp)

doHpsOverTime :: ∀ m. MonadGame m => m ()
doHpsOverTime = traverse_ doHpOverTime Slot.all