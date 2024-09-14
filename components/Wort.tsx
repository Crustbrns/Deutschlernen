import React, {useEffect, useRef} from 'react';
import {
  Animated,
  Dimensions,
  PanResponder,
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
  const pan = useRef(new Animated.ValueXY({x: 0, y: 0})).current;
  const angle = useRef(new Animated.Value(0));
  const opacity = useRef(new Animated.Value(1));
  const lockX = useRef(true);
  let isVerticalSwipe = false;

  const panResponder = useRef(
    PanResponder.create({
      onMoveShouldSetPanResponder: (evt, gestureState) => {
        const {dx, dy} = gestureState;
        // Проверяем, есть ли большее перемещение по горизонтали или вертикали
        if (Math.abs(dx) > Math.abs(dy)) {
          // Если большее смещение по горизонтали — включаем PanResponder
          return true;
        }
        // Если большее смещение по вертикали — пусть ScrollView обрабатывает
        return false;
      },
      onPanResponderMove: (evt, gestureState) => {
        lockX.current = Math.abs(gestureState.dx) > 100;
        pan.setValue({
          x: gestureState.dx,
          y: gestureState.dy,
        });
        angle.current.setValue(
          Math.atan2(gestureState.dx * -6, 8000 - gestureState.moveY),
        );
        // console.log(angle.current);
      },
      onPanResponderRelease: () => {
        console.log(pan.x, pan.y);
        lockX.current = true;

        if (
          Math.abs(Number.parseInt(JSON.stringify(pan.x))) >=
          Dimensions.get('screen').width / 2
        ) {
          Animated.timing(opacity.current, {
            toValue: 0,
            duration: 500, // Длительность анимации в миллисекундах (500 мс)
            useNativeDriver: false,
          }).start();
        } else {
          Animated.timing(pan, {
            toValue: {x: 0, y: 0},
            duration: 500, // Длительность анимации в миллисекундах (500 мс)
            useNativeDriver: false,
          }).start();
        }
        // pan.setValue({
        //   x: 20*0,
        //   y: 20*0,
        // });

        Animated.timing(angle.current, {
          toValue: 0,
          duration: 500, // Длительность анимации в миллисекундах (500 мс)
          useNativeDriver: false,
        }).start();
        // pan.extractOffset();
        console.log(pan.x, pan.y);
      },
    }),
  ).current;

  //   const fadeOut = () => {
  //     // Will change fadeAnim value to 0 in 3 seconds
  //     Animated.(fadeAnim, {
  //       toValue: 0,
  //       duration: 3000,
  //       useNativeDriver: true,
  //     }).start();
  //   };

  return (
    <SafeAreaView style={styles.main_container}>
      <Animated.View
        style={{
          transform: [
            {translateX: pan.x},
            {translateY: pan.y},
            {
              scale: angle.current.interpolate({
                inputRange: [-0.5, 0, 0.5],
                outputRange: [0.4, 1, 0.4],
              }),
            },
            {
              rotateZ: angle.current.interpolate({
                inputRange: [-1, 1],
                outputRange: ['45deg', '-45deg'],
              }),
            },
            // {rotateY: `rotate(${pan.x}deg) !important`},
          ],
          opacity: opacity.current.interpolate({
            inputRange: [0, 1],
            outputRange: [0, 1],
          }),
        }}
        {...panResponder.panHandlers}>
        <ScrollView
          scrollEnabled={!isVerticalSwipe}
          onTouchMove={event => {
            console.log('moving');
          }}
          onTouchStart={event => {
            event.stopPropagation();
            event.preventDefault();
            console.log('started clicking');
          }}
          style={styles.container}>
          <Animated.View>
            {/* <Text style={styles.text}>{props.wort}</Text> */}
            <View style={styles.title_container}>
              <View style={styles.color_box}></View>
              <Text style={styles.text_title}>
                Изучение слова
              </Text>
            </View>
            <Bild />
            <Antwort />
          </Animated.View>
        </ScrollView>
      </Animated.View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  main_container: {
    width: Dimensions.get('screen').width,
    height: Dimensions.get('window').height * 0.94,
    padding: 10,
    backgroundColor: '#090909',
  },
  container: {
    position: 'absolute',
    top: 50,
    left: 20,
    padding: 30,
    flex: 1,
    height: 550,
    transform: 'rotate(0deg)',
    // height: 1000,
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
