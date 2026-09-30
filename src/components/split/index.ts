import SplitHost from './SplitHost';
import SplitScreen from './SplitScreen';
import SplitHeaderConfig from './SplitHeaderConfig';

export type {
  DisplayModeWillChangeEvent, // TODO: This event should be renamed to match the convention
  SplitDisplayModeButtonVisibility,
  SplitBehavior,
  SplitPrimaryEdge,
  SplitPrimaryBackgroundStyle,
  SplitDisplayMode,
  SplitHostOrientation,
  SplitColumnMetrics,
  SplitNavigableColumn,
  SplitHostCommands,
  SplitHostProps,
} from './SplitHost.types';

export type {
  SplitScreenColumnType,
  SplitScreenActivityMode,
  SplitScreenDismissEvent,
  SplitScreenProps,
  SplitStackProps,
} from './SplitScreen.types';

export type {
  SplitHeaderConfigProps,
  SplitHeaderConfigRef,
} from './SplitHeaderConfig.types';

export const Split = {
  Host: SplitHost,
  Column: SplitScreen.Column,
  Stack: SplitScreen.Stack,
  Screen: SplitScreen.Screen,
  Inspector: SplitScreen.Inspector,
  HeaderConfig: SplitHeaderConfig,
};
