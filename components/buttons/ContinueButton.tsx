import React from 'react';
import {StyleSheet, Text, View} from 'react-native';

type ContinueButtonProps = {
  func: any;
  text: string;
  rely: number;
  direction: any;
  color: string;
};

function ContinueButton({func, text, rely, direction, color}: ContinueButtonProps) {
  return (
    <View
      style={[
        styles.container,
        rely === direction ? {backgroundColor: color} : '',
      ]}>
      <Text style={[styles.text, 
        rely === direction ? {color: 'white'} : '',
    ]}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 12,
    paddingHorizontal: 4,
    // borderWidth: 1,
    borderRadius: 10,
    borderColor: 'white',
    flex: 1,
    textAlign: 'center',
    alignItems: 'center',
  },
  text: {
    color: '#464646',
    fontSize: 14,
    fontFamily: 'WorkSans-Regular',
  },
});

export default ContinueButton;
