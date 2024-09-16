/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, {useState} from 'react';
import type {PropsWithChildren} from 'react';
import {
  Dimensions,
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
import {Word} from './src/classes/Word';
import {wordsManager} from './src/classes/WordsManager';
import Feather from 'react-native-vector-icons/Feather';
import ButtonBack from './components/buttons/ButtonBack';

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
      {index >= words.length && (
        <View style={styles.container}>
          <View style={styles.holder}>
            <Text><Feather name='thumbs-up' size={40} color={'#ea1d5d'}/></Text>
            <Text style={styles.text}>Все слова пройдены</Text>
            <Text style={styles.text_small}>Неизвестные слова были добавлены в список изучаемых слов</Text>
            <ButtonBack/>
          </View>
        </View>
      )}
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  highlight: {
    fontWeight: '700',
  },
  container: {
    width: Dimensions.get('screen').width,
    height: Dimensions.get('screen').height,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#090909',
  },
  holder: {
    width: Dimensions.get('screen').width - 40,
    borderRadius: 20,
    padding: 30,
    alignItems: 'center',
    backgroundColor: '#191919',
    gap: 10
  },
  text: {
    color: '#efe9e5',
    fontSize: 20,
    fontFamily: 'WorkSans-Regular',
    marginTop: 5
  },
  text_small: {
    color: '#86898c',
    fontSize: 18,
    fontFamily: 'WorkSans-Regular',
    textAlign: 'center',
    marginBottom: 15
  },
});

export default App;
