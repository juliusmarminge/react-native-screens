import type { ScenarioGroup } from '@apps/tests/shared/helpers';
import TestSplitTopColumnForCollapsing from './test-top-column-for-collapsing';
import TestSplitCommandShowColumn from './test-command-show-column';
import TestSplitColorScheme from './test-split-color-scheme-ios';
import TestSplitPressables from './test-split-pressables-ios';
import TestSplitStackColumns from './test-split-stack-columns-ios';
import TestSplitEmptyStackColumns from './test-split-empty-stack-columns-ios';
import TestSplitColumnVisibility from './test-split-column-visibility-ios';

export { default as TestSplitTopColumnForCollapsing } from './test-top-column-for-collapsing';
export { default as TestSplitCommandShowColumn } from './test-command-show-column';
export { default as TestSplitColorScheme } from './test-split-color-scheme-ios';
export { default as TestSplitPressables } from './test-split-pressables-ios';
export { default as TestSplitStackColumns } from './test-split-stack-columns-ios';
export { default as TestSplitEmptyStackColumns } from './test-split-empty-stack-columns-ios';
export { default as TestSplitColumnVisibility } from './test-split-column-visibility-ios';

const scenarios = {
  TestSplitTopColumnForCollapsing,
  TestSplitCommandShowColumn,
  TestSplitColorScheme,
  TestSplitPressables,
  TestSplitStackColumns,
  TestSplitEmptyStackColumns,
  TestSplitColumnVisibility,
};

const SplitScenarioGroup: ScenarioGroup<keyof typeof scenarios> = {
  name: 'Split',
  details: 'Single feature tests for Split',
  scenarios,
};

export default SplitScenarioGroup;
