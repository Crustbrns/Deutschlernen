import React, {useState} from 'react';
import {Dimensions, StyleSheet, Text, View} from 'react-native';
import EntypoIcon from 'react-native-vector-icons/Feather';
import IconButton from './buttons/IconButton';

type AntwortProps = {
  antwort: string;
};

function Antwort({antwort}: AntwortProps) {
  const [show, setShow] = useState(false);

  function displayArtikel() {
    if (antwort.length > 3 && antwort[3] === ' ') {
      let artikel = antwort.slice(0, 3);
      if (artikel === 'der') {
        return (
          <Text style={[styles.artikel, {color: '#0087d2'}]}>{artikel}</Text>
        );
      } else if (artikel === 'das') {
        return (
          <Text style={[styles.artikel, {color: '#0eb24e'}]}>{artikel}</Text>
        );
      } else if (artikel === 'die') {
        return (
          <Text style={[styles.artikel, {color: '#cd004b'}]}>{artikel}</Text>
        );
      }
    }
  }

  return (
    <View>
      <View style={styles.container}>
        <View style={styles.triangle}></View>
        <View style={styles.line}></View>
      </View>
      <Text>
        <IconButton icon={<EntypoIcon name="eye" size={30} color="white" />} />
      </Text>
      {!show && <View></View>}
      {show && (
        <Text style={styles.text}>
          {displayArtikel()}
          {antwort.slice(3)}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    marginVertical: 20,
  },
  triangle: {
    position: 'absolute',
    width: 15,
    height: 15,
    borderBottomWidth: 1,
    borderLeftWidth: 1,
    backgroundColor: '#191919',
    borderColor: '#2F2F2F',
    zIndex: 10,
    opacity: 1,
    transform: 'rotate(-45deg)',
  },
  line: {
    width: Dimensions.get('window').width - 90,
    height: 1,
    backgroundColor: '#2F2F2F',
  },
  artikel: {
    color: '#007fdb',
  },
  text: {
    color: '#eeeeee',
    opacity: 0.9,
    fontSize: 40,
  },
});

export default Antwort;
