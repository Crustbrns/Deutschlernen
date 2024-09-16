import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';

type BildProps = {
    thema: string,
    image: string,
    word: string
}

function Bild({thema, image, word} : BildProps) {
    return (
        <View style={styles.container}>
            <Text style={styles.title}>{thema}</Text>
            <Image style={styles.image} src={image}/>
            <Text style={styles.wort}>{word}</Text>
        </View>
    );
}


const styles = StyleSheet.create({
    container: {
        marginTop: 30,
        gap: 18,
        flexDirection: 'column',
        flex: 1
    },
    image: {
        width: 160,
        height: 100,
        borderRadius: 15
    },
    title: {
        color: '#86898c',
        fontSize: 16,
        opacity: 0.7,
        fontFamily: 'WorkSans-Thin'
    },
    wort: {
        fontSize: 45,
        lineHeight: 45,
        textTransform: 'lowercase',
        color: '#eeeeee',
        opacity: 0.9,
        fontFamily: 'WorkSans-Regular'
    }
});

export default Bild;