import React, { forwardRef } from 'react';
import { StackHeaderConfig } from '../stack/header';
import type {
  SplitHeaderConfigProps,
  SplitHeaderConfigRef,
} from './SplitHeaderConfig.types';

/**
 * EXPERIMENTAL API, MIGHT CHANGE W/O ANY NOTICE
 *
 * The header of a column screen. Natively it is the same neutral header config `Stack.HeaderConfig` renders
 * (`RNSHeaderConfigIOS`); the component and its props type are Split's own entry point to it.
 */
function SplitHeaderConfig(
  props: SplitHeaderConfigProps,
  ref: React.Ref<SplitHeaderConfigRef>,
) {
  return <StackHeaderConfig ref={ref} {...props} />;
}

export default forwardRef<SplitHeaderConfigRef, SplitHeaderConfigProps>(
  SplitHeaderConfig,
);
