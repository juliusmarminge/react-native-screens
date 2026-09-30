'use client';

import type {
  CodegenTypes as CT,
  HostComponent,
  ViewProps,
} from 'react-native';
import { codegenNativeComponent } from 'react-native';

// eslint-disable-next-line @typescript-eslint/ban-types
type GenericEmptyEvent = Readonly<{}>;

type SplitScreenColumnType = 'column' | 'inspector';

type ActivityMode = 'detached' | 'attached';

type OnDismissEventPayload = Readonly<{
  isNativeDismiss: boolean;
}>;

interface NativeProps extends ViewProps {
  // Config
  columnType?: CT.WithDefault<SplitScreenColumnType, 'column'>;
  column?: CT.WithDefault<CT.Int32, -1>;
  activityMode?: CT.WithDefault<ActivityMode, 'attached'>;
  screenKey?: string | undefined;

  // Events
  onWillAppear?: CT.DirectEventHandler<GenericEmptyEvent> | undefined;
  onDidAppear?: CT.DirectEventHandler<GenericEmptyEvent> | undefined;
  onWillDisappear?: CT.DirectEventHandler<GenericEmptyEvent> | undefined;
  onDidDisappear?: CT.DirectEventHandler<GenericEmptyEvent> | undefined;
  onDismiss?: CT.DirectEventHandler<OnDismissEventPayload> | undefined;
}

export default codegenNativeComponent<NativeProps>('RNSSplitScreen', {
  interfaceOnly: true,
}) as HostComponent<NativeProps>;
