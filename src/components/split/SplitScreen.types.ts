import type { NativeSyntheticEvent, ViewProps } from 'react-native';

// eslint-disable-next-line @typescript-eslint/ban-types
type GenericEmptyEvent = Readonly<{}>;

export type SplitScreenColumnType = 'column' | 'inspector';

export type SplitScreenActivityMode = 'detached' | 'attached';

export type SplitScreenDismissEvent = Readonly<{
  isNativeDismiss: boolean;
}>;

export interface SplitStackProps {
  children?: React.ReactNode | undefined;
}

export interface SplitScreenProps extends ViewProps {
  children?: React.ReactNode | undefined;
  /**
   * @summary Whether the screen is expected to be on the stack of its column. Defaults to `attached`.
   */
  activityMode?: SplitScreenActivityMode | undefined;
  /**
   * @summary Identifier of the screen, used for debugging only.
   */
  screenKey?: string | undefined;
  /**
   * @summary A callback that gets invoked when the screen left the stack of its column, either after it was
   * detached or after a native dismissal (e.g. the back button).
   */
  onDismiss?:
    | ((e: NativeSyntheticEvent<SplitScreenDismissEvent>) => void)
    | undefined;
  /**
   * @summary A callback that gets invoked when the current SplitScreen did appear.
   *
   * This is called as soon as the transition ends.
   */
  onDidAppear?:
    | ((e: NativeSyntheticEvent<GenericEmptyEvent>) => void)
    | undefined;
  /**
   * @summary A callback that gets invoked when the current SplitScreen did disappear.
   *
   * This is called as soon as the transition ends.
   */
  onDidDisappear?:
    | ((e: NativeSyntheticEvent<GenericEmptyEvent>) => void)
    | undefined;
  /**
   * @summary A callback that gets invoked when the current SplitScreen will appear.
   *
   * This is called as soon as the transition begins.
   */
  onWillAppear?:
    | ((e: NativeSyntheticEvent<GenericEmptyEvent>) => void)
    | undefined;
  /**
   * @summary A callback that gets invoked when the current SplitScreen will disappear.
   *
   * This is called as soon as the transition begins.
   */
  onWillDisappear?:
    | ((e: NativeSyntheticEvent<GenericEmptyEvent>) => void)
    | undefined;
}
