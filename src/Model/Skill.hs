module Model.Skill
  ( Skill(..), new, targets, chakraClasses
  , Target(..)
  , Transform
  , defaultName
  ) where

import ClassyPrelude
import Data.Enum.Set.Class (EnumSet)

import           Model.Internal (Skill(..), Requirement(..), Target(..), Copying(..), Ninja)
import           Model.Channel (Channeling(..))
import qualified Model.Chakra as Chakra
import qualified Model.Runnable as Runnable

-- | The type signature of 'changes'.
type Transform = (Ninja -> Skill -> Skill)

-- | Default values.
new :: Skill
new = Skill { name      = "Unnamed"
            , desc      = ""
            , require   = Usable
            , classes   = mempty
            , cost      = 0
            , cooldown  = 0
            , varicd    = False
            , charges   = 0
            , dur       = Instant
            , start     = []
            , effects   = []
            , interrupt = []
            , changes   = const id
            , copying   = NotCopied
            , pic       = False
            }

targets :: Skill -> EnumSet Target
targets x = setFromList $
            Runnable.target <$> start x ++ effects x ++ interrupt x

-- | Adds 'Model.Class.Bloodline', 'Model.Class.Genjutsu',
-- 'Model.Class.Ninjutsu', 'Model.Class.Taijutsu', and 'Model.Class.Random'
-- to the 'classes' of a @Skill@ if they are included in its 'cost'.
chakraClasses :: Skill -> Skill
chakraClasses skill =
    skill { classes = Chakra.classes (cost skill) ++ classes skill }

-- | Replaces an empty string with a 'name'.
defaultName :: Text -> Skill -> Text
defaultName ""   skill = name skill
defaultName name _     = name
