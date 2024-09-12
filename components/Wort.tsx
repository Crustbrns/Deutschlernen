import React from 'react';
import {
  Dimensions,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import Bild from './Bild';
import Antwort from './Antwort';

type WortProps = {
  wort: string;
};

function Wort(props: WortProps) {
  return (
    <SafeAreaView style={styles.main_container}>
      <ScrollView style={styles.container}>
        {/* <Text style={styles.text}>{props.wort}</Text> */}
        <View style={styles.title_container}>
          <View style={styles.color_box}></View>
          <Text style={styles.text_title}>Изучение слова</Text>
        </View>
        <Bild />
        <Antwort />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  main_container: {
    width: Dimensions.get('screen').width,
    height: Dimensions.get('window').height * 0.94,
    display: 'flex',
    flexDirection: 'column',
    paddingVertical: 60,
    alignContent: 'center',
    alignItems: 'center',
    padding: 10,
    backgroundColor: '#090909',
  },
  container: {
    padding: 30,
    flex: 1,
    height: 1000,
    width: Dimensions.get('screen').width - 40,
    // width: '90%',
    backgroundColor: '#191919',
    borderRadius: 20,
  },
  title_container: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
  },
  color_box: {
    width: 15,
    height: 15,
    backgroundColor: 'orange',
    borderRadius: 4,
  },
  text_title: {
    color: '#efe9e5',
    fontSize: 20,
  },
  text: {
    color: 'white',
  },
  highlight: {
    fontWeight: '700',
  },
});

export default Wort;
