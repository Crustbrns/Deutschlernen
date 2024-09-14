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

class Word {
  thema: string;
  image: string;
  word: string;
  antwort: string;

  constructor(thema: string, image: string, word: string, antwort: string) {
    this.thema = thema;
    this.image = image;
    this.word = word;
    this.antwort = antwort;
  }
}

function App(): React.JSX.Element {
  const isDarkMode = useColorScheme() === 'dark';
  const [index, setIndex] = useState(0);
  const [words, setWords] = useState(
    new Array<Word>(
      new Word(
        'Предметы в быту',
        'https://www.raten-kauf.com/pre/wp-content/uploads/sites/2/2020/04/Herd-auf-Raten-kaufen.png',
        'Печка, печь, плита',
        'der Herd (die Herde)'
      ),
      new Word(
        'Предметы в быту',
        'https://cdn.domdivanov74.com/files/imgs/ig1812128/polka-navesnaya-lesenka-2-1-590x430.jpg',
        'Полка',
        'das Regal (die Regale)'
      ),
      new Word(
        'Предметы в быту',
        'https://www.einrichten-design.de/media/c8/53/33/1599490339/Tische_Erlebniswelt001.jpg',
        'Стол',
        'der Schrank (die Schränke)'
      ),
      new Word(
        'Предметы в быту',
        'https://mim.p7s1.io/pis/ld/6fbdzChLCVyZ-c1vEwXZAanB-DJ78rnq2V2gRWTHzVV6NywNWMSJCEGmZ4YSENP-WRL0b9lo2z78G9xHvKKzhYXqxw1zZuKZsDZpdm1Zy1ghi1QS0txqlw5oWww8zRIMVxLDAWzGW0I/profile:original?rect=0%2C625%2C6000%2C3375&w=1070',
        'Сумка',
        'die Tasche (die Taschen)'
      ),
    ),
  );

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
