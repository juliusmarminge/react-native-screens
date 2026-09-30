import React from 'react';
import { StyleSheet } from 'react-native';
import SplitScreenNativeComponent from '../../fabric/split/SplitScreenNativeComponent';
import { SplitScreenProps, SplitStackProps } from './SplitScreen.types';

/**
 * Index of the column assigned by `Split.Host` to each `Split.Column`; read by the screens of the column.
 */
export const SplitColumnIndexContext = React.createContext<number>(-1);

/**
 * EXPERIMENTAL API, MIGHT CHANGE W/O ANY NOTICE
 *
 * A screen in the navigation stack of a column.
 */
function Screen(props: SplitScreenProps) {
  const column = React.useContext(SplitColumnIndexContext);
  return (
    <SplitScreenNativeComponent
      columnType="column"
      column={column}
      {...props}
      style={StyleSheet.absoluteFill}>
      {props.children}
    </SplitScreenNativeComponent>
  );
}

/**
 * EXPERIMENTAL API, MIGHT CHANGE W/O ANY NOTICE
 *
 * The navigation stack of a column. It has no native counterpart: its screens are mounted directly in the host and
 * routed to the column by index.
 */
function Stack(props: SplitStackProps) {
  return <>{props.children}</>;
}

/**
 * EXPERIMENTAL API, MIGHT CHANGE W/O ANY NOTICE
 *
 * A column. With a `Split.Stack` child it is a JS-only grouping of the stack's screens and must not have other
 * children; otherwise the column itself is a single screen.
 */
function Column(props: SplitScreenProps) {
  const children = React.Children.toArray(props.children);
  const hasStack = children.some(
    child => React.isValidElement(child) && child.type === Stack,
  );
  if (hasStack) {
    if (children.length > 1) {
      console.error(
        '[RNScreens] Split.Column with a Split.Stack child must not have other children',
      );
    }
    return <>{props.children}</>;
  }
  return <Screen {...props} />;
}

/**
 * EXPERIMENTAL API, MIGHT CHANGE W/O ANY NOTICE
 */
function Inspector(props: SplitScreenProps) {
  return (
    <SplitScreenNativeComponent
      columnType="inspector"
      {...props}
      style={StyleSheet.absoluteFill}>
      {props.children}
    </SplitScreenNativeComponent>
  );
}

/**
 * EXPERIMENTAL API, MIGHT CHANGE W/O ANY NOTICE
 */
// TODO: refactor to drop `Screen` suffix as the API name is really long at the moment
const SplitScreen = {
  Column,
  Stack,
  Screen,
  Inspector,
};

export default SplitScreen;
