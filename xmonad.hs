import qualified Data.Map as M
import Data.Maybe as M
import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops
import XMonad.Actions.Navigation2D
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Layout.MultiColumns
import Codec.Binary.UTF8.String (encode)

nav2dconfig = Navigation2DConfig { defaultTiledNavigation = centerNavigation,
                                   floatNavigation = centerNavigation,
                                   screenNavigation = centerNavigation,
			           layoutNavigation = [],
                                   unmappedWindowRect = [("Full", singleWindowRect)] }

ifFocusedFloating :: X a -> X a -> X a
ifFocusedFloating floatingAction otherAction = do
    winset <- gets windowset
    case W.peek winset >>= flip M.lookup (W.floating winset) of
        Just _ -> floatingAction
        otherwise -> otherAction

sendToBottom' (W.Stack x l []) = W.Stack x l []
sendToBottom' (W.Stack x l r ) = W.Stack x (reverse r ++ l) []
sendToBottom = W.modify' sendToBottom'

setRootPropertyStrings :: String -> [String] -> X ()
setRootPropertyStrings atom ns = withDisplay $ \d -> do
    root <- asks theRoot
    atom' <- getAtom atom
    utf8' <- getAtom "UTF8_STRING"
    let u8data = concatMap((++[0]).encode) ns
    io $ changeProperty8 d root atom' utf8' propModeReplace (map fromIntegral u8data)

setVisibleHook :: X()
setVisibleHook = withWindowSet $ \s -> do
    setRootPropertyStrings "_XMONAD_VISIBLE_WORKSPACES" $ map (W.tag . W.workspace) (W.visible s)

wmKeys config = mkKeymap config $
    [("M-x", spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"),
     ("M-t", spawn (terminal config)),
     ("M-f", spawn "firefox"),
     ("M-l", spawn "xset s activate"),
     ("M-<Print>", spawn "volume-down"),
     ("M-<Pause>", spawn "volume-up"),
     ("M-]", sendMessage $ IncMasterN 1),
     ("M-[", sendMessage $ IncMasterN (-1)),
     ("M-S-.", sendMessage $ Expand),
     ("M-S-,", sendMessage $ Shrink),
     ("M-.", withFocused $ windows . W.sink),
     ("M-C-<Delete>", kill),
     ("M-<Page_Down>", sendMessage $ NextLayout),
     ("M-<Home>", setLayout $ layoutHook config),
     ("M-<Tab>", windows W.focusDown),
     ("M-S-<Tab>", windows W.focusUp),
     ("M-<Left>", windowGo L False),
     ("M-<Up>", windowGo U False),
     ("M-<Right>", windowGo R False),
     ("M-<Down>", windowGo D False),
     ("M-S-<Left>", screenGo L False),
     ("M-S-<Up>", screenGo U False),
     ("M-S-<Right>", screenGo R False),
     ("M-S-<Down>", screenGo D False),
     ("M-C-S-<Left>", windowToScreen L False),
     ("M-C-S-<Up>", windowToScreen U False),
     ("M-C-S-<Right>", windowToScreen R False),
     ("M-C-S-<Down>", windowToScreen D False),
     ("M-C-<Left>", windowSwap L False),
     ("M-C-<Up>", ifFocusedFloating (windows W.swapMaster) (windowSwap U False)),
     ("M-C-<Right>", windowSwap R False),
     ("M-C-<Down>", ifFocusedFloating (windows sendToBottom) (windowSwap D False))]
    ++
    [("M-"++show n, windows (W.view w)) | (n,w) <- zip [1..9] (workspaces config)]
    ++
    [("M-C-"++show n, windows (W.shift w)) | (n,w) <- zip [1..9] (workspaces config)]

wmLayout = columns ||| Mirror columns ||| simpleTabbed
    where columns = multiCol [1,1] 3 (3/100) (1/3)

main = xmonad $ docks $ ewmh $ withNavigation2DConfig nav2dconfig $ defaultConfig
   {
      manageHook = manageDocks <+> manageHook defaultConfig,
      layoutHook = (avoidStruts $ wmLayout) ||| noBorders Full,
      handleEventHook = handleEventHook defaultConfig <+> fullscreenEventHook,
      logHook = setVisibleHook,
      modMask = mod4Mask,
      keys = wmKeys,
      terminal = "urxvt"
   }
