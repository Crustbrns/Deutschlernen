import React, {useState} from 'react';
import {StyleSheet, Text, View} from 'react-native';

type ButtonBackProps = {};

function ButtonBack() {
  const [hover, setHover] = useState(false);

  function ChangeHover(hover: boolean) {
    setHover(hover);
  }

  return (
    <View
      onTouchStart={() => ChangeHover(true)}
      onTouchEnd={() => {
        ChangeHover(false);
      }}
      style={[styles.container, hover ? styles.container_hover : '']}>
      <Text style={styles.text}>Вернуться обратно</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 15,
    borderRadius: 10,
    borderColor: 'white',
    borderWidth: 1,
    width: '100%',
  },
  container_hover: {
    backgroundColor: '#222',
  },
  text: {
    color: '#efe9e5',
    fontSize: 20,
    fontFamily: 'WorkSans-Regular',
    textAlign: 'center',
  },
});

export default ButtonBack;
