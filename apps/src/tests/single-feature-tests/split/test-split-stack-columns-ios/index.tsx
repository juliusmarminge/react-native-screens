import React from 'react';
import { Button, StyleSheet, Text, View } from 'react-native';
import { Split } from 'react-native-screens';
import { createScenario } from '@apps/tests/shared/helpers';
import { scenarioDescription } from './scenario-description';

type Column = 'primary' | 'secondary';
type ScreenState = { key: string; activityMode: 'attached' | 'detached' };

const attached = (key: string): ScreenState => ({
  key,
  activityMode: 'attached',
});

const title = (key: string) =>
  key.replace('-', ' ').replace(/^\w/, c => c.toUpperCase());

/**
 * Both columns are stacks of screens driven by state.
 *
 * A pop detaches the top screen first and removes it from the state once the screen reports its dismissal, so that
 * its content survives the pop transition. A native pop (back button, back gesture, back button menu) reports the
 * dismissal of every popped screen, each of which then leaves the state on its own.
 */
function TestSplitStackColumns() {
  const [screens, setScreens] = React.useState<Record<Column, ScreenState[]>>({
    primary: [attached('primary-0')],
    secondary: [attached('secondary-0')],
  });
  const nextId = React.useRef(1);

  const push = (column: Column) =>
    setScreens(state => ({
      ...state,
      [column]: [...state[column], attached(`${column}-${nextId.current++}`)],
    }));

  const pop = (column: Column) =>
    setScreens(state => {
      const stack = state[column];
      const attachedScreens = stack.filter(
        screen => screen.activityMode === 'attached',
      );
      if (attachedScreens.length <= 1) {
        return state;
      }
      const top = attachedScreens[attachedScreens.length - 1];
      return {
        ...state,
        [column]: stack.map(screen =>
          screen === top ? { ...screen, activityMode: 'detached' } : screen,
        ),
      };
    });

  const remove = (column: Column, key: string) =>
    setScreens(state => ({
      ...state,
      [column]: state[column].filter(screen => screen.key !== key),
    }));

  const renderColumn = (column: Column, hue: number) => (
    <Split.Column>
      <Split.Stack>
        {screens[column].map((screen, index) => (
          <Split.Screen
            key={screen.key}
            screenKey={screen.key}
            activityMode={screen.activityMode}
            onDismiss={() => remove(column, screen.key)}>
            <Split.HeaderConfig title={title(screen.key)} />
            <ScreenContent
              title={title(screen.key)}
              hue={hue + index * 25}
              onPush={push}
              onPop={pop}
            />
          </Split.Screen>
        ))}
      </Split.Stack>
    </Split.Column>
  );

  return (
    <Split.Host
      preferredDisplayMode="oneBesideSecondary"
      preferredSplitBehavior="tile">
      {renderColumn('primary', 210)}
      {renderColumn('secondary', 120)}
    </Split.Host>
  );
}

function ScreenContent(props: {
  title: string;
  hue: number;
  onPush: (column: Column) => void;
  onPop: (column: Column) => void;
}) {
  return (
    <View
      style={[
        styles.container,
        { backgroundColor: `hsl(${props.hue}, 70%, 85%)` },
      ]}>
      <Text style={styles.title}>{props.title}</Text>
      <Button title="Push primary" onPress={() => props.onPush('primary')} />
      <Button title="Pop primary" onPress={() => props.onPop('primary')} />
      <Button
        title="Push secondary"
        onPress={() => props.onPush('secondary')}
      />
      <Button title="Pop secondary" onPress={() => props.onPop('secondary')} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
  },
});

export default createScenario(TestSplitStackColumns, scenarioDescription);
