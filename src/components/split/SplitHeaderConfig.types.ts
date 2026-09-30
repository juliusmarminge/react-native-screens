import type {
  StackHeaderConfigProps,
  StackHeaderConfigRef,
} from '../stack/header';

/**
 * Props of `Split.HeaderConfig`.
 *
 * The header of a column screen is configured exactly like the header of a stack screen. The type is Split's own so
 * that the Split API can evolve independently of the Stack one.
 */
export type SplitHeaderConfigProps = StackHeaderConfigProps;

export type SplitHeaderConfigRef = StackHeaderConfigRef;
