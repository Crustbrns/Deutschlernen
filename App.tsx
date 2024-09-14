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

type SectionProps = PropsWithChildren<{
  title: string;
}>;

function Section({children, title}: SectionProps): React.JSX.Element {
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
  const [index, setIndex] = useState(0);

  const HandleIndex = () =>
    setIndex(index + 1 > words.length - 1 ? words.length - 1 : index + 1);

  const backgroundStyle = {
    backgroundColor: Colors.lighter,
    // backgroundColor: isDarkMode ? Colors.darker : Colors.lighter,
  };

  class Word {
    thema: string;
    image: string;
    word: string;

    constructor(thema: string, image: string, word: string) {
      this.thema = thema;
      this.image = image;
      this.word = word;
    }
  }

  const words: Array<Word> = new Array<Word>(
    new Word(
      'Предметы в быту',
      'https://www.raten-kauf.com/pre/wp-content/uploads/sites/2/2020/04/Herd-auf-Raten-kaufen.png',
      'Печка, печь, плита',
    ),
    new Word(
      'Предметы в быту',
      'https://cdn.domdivanov74.com/files/imgs/ig1812128/polka-navesnaya-lesenka-2-1-590x430.jpg',
      'Полка',
    ),
  );

  return (
    <SafeAreaView style={backgroundStyle}>
      <StatusBar barStyle="default" backgroundColor="#000000" />
      {/* <Text>Hello m8</Text> */}
      <WordsCount />
{/* 
      <View
        style={{zIndex: 10, width: 60, height: 40, backgroundColor: 'red'}}
        onTouchStart={HandleIndex}></View> */}

      <Wort
        thema={words[index].thema}
        image={words[index].image}
        word={words[index].word}
        HandleIndex={HandleIndex}
      />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  highlight: {
    fontWeight: '700',
  },
});

export default App;
