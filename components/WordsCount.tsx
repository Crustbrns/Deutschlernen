import React from 'react';
import {Dimensions, StyleSheet, Text, View} from 'react-native';

function WordsCount() {
  return (
    <View style={styles.container}>
      <View></View>
      <View>
        <View>
          <Text style={styles.text}>Слов повторено</Text>
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
    paddingVertical: 5
  },
  text: {
    color: '#86898c',
    fontSize: 16,
    opacity: 0.7,
  },
});

export default WordsCount;
