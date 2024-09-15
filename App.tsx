/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */


import React, {useState} from 'react';
import type {PropsWithChildren} from 'react';
import {
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  useColorScheme,
  View,
} from 'react-native';

import {
  Colors,
  DebugInstructions,
  Header,
  LearnMoreLinks,
  ReloadInstructions,
} from 'react-native/Libraries/NewAppScreen';
import Wort from './components/Wort';
import WordsCount from './components/WordsCount';
import { Word } from './src/classes/Word';
import { wordsManager } from './src/classes/WordsManager';


function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [index, setIndex] = useState(0);
  const [words, setWords] = useState(wordsManager);

  const HandleIndex = () =>
    setIndex(index => (index + 1 > words.length ? words.length : index + 1));
  console.log(index, words.length);

  const backgroundStyle = {
    backgroundColor: Colors.lighter,
    // backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };
  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar barStyle="default" backgroundColor="#000000" />
      {/* <Text>Hello m8</Text> */}
      <WordsCount index={index} words={words} />
      {/* 
      <View
        style={{zIndex: 10, width: 60, height: 40, backgroundColor: 'red'}}
        onTouchStart={HandleIndex}></View> */}

      {index < words.length && (
        <Wort
          thema={words[index].thema}
          image={words[index].image}
          word={words[index].word}
          antwort={words[index].antwort}
          HandleIndex={HandleIndex}
        />
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  highlight: {
    fontWeight: '700',
  },
});

export default App;
