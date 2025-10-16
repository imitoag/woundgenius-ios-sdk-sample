/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useState} from 'react';
import {
  StyleSheet,
  Text,
  TextInput,
  Button,
  Alert,
  Image
} from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';

import NativeLocalStorage from './specs/NativeLocalStorage';

const EMPTY = '<empty>';

function App(): React.JSX.Element {
  // 2. Use useState to store and display the result from the native call
  const [captureResult, setCaptureResult] = useState<string>('');

  // 3. Create an async function to call the native method
  const handleStartCapture = async () => {
    try {
      // 4. Use 'await' to wait for the promise to resolve
      console.log('Calling native startCapturing...');
      const result = await NativeLocalStorage.startCapturing();
      
      // 5. Update the component's state with the result
      console.log('Native method returned:', result);
      setCaptureResult(result);

    } catch (error) {
      // 6. Handle any errors if the promise is rejected
      console.error(error);
      Alert.alert('Error', 'Failed to start capture.');
    }
  };


  const [value, setValue] = React.useState<string | null>(null);

  const [editingValue, setEditingValue] = React.useState<
    string | null
  >(null);

  React.useEffect(() => {
    const storedValue = NativeLocalStorage?.getItem('myKey');
    setValue(storedValue ?? '');
  }, []);

  function saveValue() {
    NativeLocalStorage?.setItem(editingValue ?? EMPTY, 'myKey');
    setValue(editingValue);
  }

  function clearAll() {
    NativeLocalStorage?.clear();
    setValue('');
  }

  function deleteValue() {
    NativeLocalStorage?.removeItem('myKey');
    setValue('');
  }

  return (
        <SafeAreaProvider>
    <SafeAreaView>
      <Text style={styles.text}>
        Current stored value is: {value ?? 'No Value'}
      </Text>
      <TextInput
        placeholder="Enter the text you want to store"
        style={styles.textInput}
        onChangeText={setEditingValue}
      />
      <Button title="Save" onPress={saveValue} />
      <Button title="Delete" onPress={deleteValue} />
      <Button title="Clear" onPress={clearAll} />
      <Button title="Start Capturing" onPress={handleStartCapture} />
      {/* 2. Conditionally render the Image component */}
        {captureResult ? (
          <Image
            style={styles.capturedImage}
            source={{ uri: `data:image/jpeg;base64,${captureResult}` }}
          />
        ) : (
          <Text style={styles.text}>No image captured yet.</Text>
        )}
    </SafeAreaView>
            </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  text: {
    margin: 10,
    fontSize: 20,
  },
  textInput: {
    margin: 10,
    height: 40,
    borderColor: 'black',
    borderWidth: 1,
    paddingLeft: 5,
    paddingRight: 5,
    borderRadius: 5,
  },
    capturedImage: {
    width: 250,
    height: 250,
    margin: 10,
    alignSelf: 'center',
    borderColor: '#999',
    borderWidth: 1,
    borderRadius: 5,
  },
});

export default App;