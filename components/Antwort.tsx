import React from 'react';
import {Dimensions, StyleSheet, Text, View} from 'react-native';

function Antwort() {
  return (
    <View>
      <View style={styles.container}>
        <View style={styles.line}></View>
      </View>
      <Text style={styles.text}>
        <Text style={styles.artikel}>der</Text> Herd (die Herde)
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    marginVertical: 20
  },
  line: {
    width: Dimensions.get("window").width - 70,
    height: 1,
    backgroundColor: '#eeeeee',
    opacity: 0.1,
  },
  artikel: {
    color: '#0085c3',
  },
  text: {
    color: '#eeeeee',
    opacity: 0.9,
    fontSize: 40,
  },
});

export default Antwort;
