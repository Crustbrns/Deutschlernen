import React from 'react';
import {Dimensions, StyleSheet, Text, View} from 'react-native';
import { Colors } from 'react-native/Libraries/NewAppScreen';

type WordsProps = {
    index: any,
    words: any
}

function WordsCount({index, words} : WordsProps) {

  return (
    <View style={styles.container}>
      <View></View>
      <View>
        <View>
          <Text style={styles.text}><Text style={styles.index}>{index}</Text> Слов пройдено</Text>
        </View>
        <View style={[styles.flex_container, {gap: words.length < 6 ? 15 : words.length * 3 / 10}]}>
          {words.map((x:any, i:number) => {
            return <View style={[styles.word_container, {backgroundColor: i <= index-1 ? "#ea1d5d" : "#333333"}]} key={i}></View>;
          })}
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: Dimensions.get('screen').width,
    height: 80,
    position: 'absolute',
    zIndex: 10,
    backgroundColor: '#090909',
    flex: 1,
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    paddingVertical: 5,
    paddingBottom: 12
  },
  index: {
    fontSize: 20,
    color: 'white',
    fontFamily: 'WorkSans-Regular',
  },
  text: {
    color: '#86898c',
    fontSize: 16,
    opacity: 0.7,
    fontFamily: 'WorkSans-Regular'
  },
  flex_container: {
    gap: 10,
    flexDirection: 'row',
    marginTop: 7
  },
  word_container: {
    flex: 1,
    borderRadius: 10,
    height: 5,
    backgroundColor: '#333333',
  },
});

export default WordsCount;
