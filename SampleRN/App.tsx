/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useEffect, useState } from 'react';
import type { PropsWithChildren } from 'react';

import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  Image,
  useColorScheme,
  View,
  Button,
  NativeModules,
  NativeEventEmitter,
  Dimensions,
} from 'react-native';

import {
  Colors,
  DebugInstructions,
  Header,
  LearnMoreLinks,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';

const WoundGeniusRNEvents = new NativeEventEmitter(NativeModules.WoundGeniusRN);

type SectionProps = PropsWithChildren<{
  title: string;
}>;

function Section({ children, title }: SectionProps): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  return (
    <View style={styles.sectionContainer}>
      <Text
        style={[
          styles.sectionTitle,
          {
            color: isDarkMode ? Colors.white : Colors.black,
          },
        ]}>
        {title}
      </Text>
      <Text
        style={[
          styles.sectionDescription,
          {
            color: isDarkMode ? Colors.light : Colors.dark,
          },
        ]}>
        {children}
      </Text>
    </View>
  );
}

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';

  const backgroundStyle = {
    backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  const increment = async () => {
    NativeModules.WoundGeniusRN.increment(value => {
      setCount(value);
    });
  }

  const capture = async () => {
    NativeModules.WoundGeniusRN.startCapturing();
  }

  const decrement = async () => {
    try {
      var result = await NativeModules.WoundGeniusRN.decrement()
      setCount(result);
    } catch (e) {
      console.log(e.message, e.code);
    }
  }

  useEffect(() => {
    WoundGeniusRNEvents.addListener("onImage", result => {
      const base64String = result.base64ImageModified; // Or base64ImageOriginal to get the original image. 
      setBase64Image(base64String);

      const metadata = JSON.stringify(result.metadata, null, 2);
      setMetadata(metadata);
    });
    return () => {
      WoundGeniusRNEvents.removeAllListeners('onImage');
    }
  }, []);

  const [count, setCount] = useState<number>(0);

  const [base64Image, setBase64Image] = useState<string | null>(null);

  const [metadata, setMetadata] = useState<string | null>(null);

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar
        barStyle={isDarkMode ? 'light-content' : 'dark-content'}
        backgroundColor={backgroundStyle.backgroundColor}
      />
      <ScrollView
        contentInsetAdjustmentBehavior="automatic"
        style={backgroundStyle}>
        <Header />
        <View
          style={{
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
          }}>
          <Section title="Start WoundGenius Capturing">
            <View style={styles.container}>
              <Button title="Start Capturing" onPress={capture} />
              {base64Image && (
                <Image
                  source={{ uri: `data:image/png;base64,${base64Image}` }}
                  style={styles.image}
                />
              )}
              {metadata && (
                <Text style={styles.label}>Metadata: {metadata}</Text>
              )}
            </View>
          </Section>
          {/* <Section title="Swift Counter Data Transfer Sample">
            <View style={styles.container}>
              <Text style={styles.label}>This is the sample to showcase the linking between Native iOS Swift and React Native.</Text>
              <Button title="Increment Swift Counter" onPress={increment} />
              <Button title="Decrement Swift Count" onPress={decrement} />
              <Text style={styles.label}>Count: {count}</Text>
            </View>
          </Section> */}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const screenWidth = Dimensions.get('window').width;

const styles = StyleSheet.create({
  sectionContainer: {
    marginTop: 32,
    paddingHorizontal: 24,
  },
  sectionTitle: {
    fontSize: 24,
    fontWeight: '600',
  },
  sectionDescription: {
    marginTop: 8,
    fontSize: 18,
    fontWeight: '400',
  },
  highlight: {
    fontWeight: '700',
  },
  label: {
    fontSize: 24,
    marginBottom: 20,
    color: 'white',
  },
  container: {
    width: '100%',
    marginBottom: 10,
  },
  image: {
    width: screenWidth * 0.8, // 80% of the screen width
    height: undefined, // Automatically calculate height to maintain aspect ratio
    aspectRatio: 1, // This will maintain the aspect ratio based on the width
  },
});

export default App;
