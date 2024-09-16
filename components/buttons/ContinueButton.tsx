import React from 'react';
import {StyleSheet, Text, View} from 'react-native';

type ContinueButtonProps = {
  func: any;
  text: string;
};

function ContinueButton({func, text}: ContinueButtonProps) {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>{text}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 12,
    paddingHorizontal: 2,
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
