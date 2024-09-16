import React, {useRef, useState} from 'react';
import {
  Animated,
  Dimensions,
  Easing,
  StyleSheet,
  Text,
  View,
} from 'react-native';
import EntypoIcon from 'react-native-vector-icons/Feather';
import IconButton from './buttons/IconButton';

type AntwortProps = {
  antwort: string;
  show: any;
  setShow: any;
};

function Antwort({antwort, show, setShow}: AntwortProps) {
  const coord = useRef(new Animated.ValueXY({x: 0, y: 15})).current;
  // const [show, setShow] = useState(false);

  function showWord() {

    if(show === false) {
      Animated.timing(coord, {
        toValue: {x: 0, y: 15},
        duration: 0,
        useNativeDriver: false,
      }).start();
    }

    Animated.timing(coord, {
      toValue: {x: 0, y: 0},
      duration: 500,
      easing: Easing.inOut(Easing.ease),
      useNativeDriver: false,
    }).start();
    setShow(true);
  }

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
      {!show && (
        <View style={styles.holder}>
        <Text>
          <IconButton
            icon={<EntypoIcon name="edit-3" size={25} color="white" />}
            func={() => showWord()}
          />
        </Text>
        <Text>
          <IconButton
            icon={<EntypoIcon name="eye" size={25} color="white" />}
            func={() => showWord()}
          />
        </Text>
        <Text>
          <IconButton
            icon={<EntypoIcon name="menu" size={25} color="white" />}
            func={() => showWord()}
          />
        </Text>
        </View>
      )}
      {show && (
        <Animated.View
          style={{
            transform: [{translateX: coord.x}, {translateY: coord.y}],
          }}>
          <Text style={styles.text}>
            {displayArtikel()}
            {antwort.slice(3)}
          </Text>
        </Animated.View>
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
  holder: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 20
  }
});

export default Antwort;
