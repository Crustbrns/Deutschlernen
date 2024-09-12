import React from 'react';
import { Image, StyleSheet, Text, View } from 'react-native';

function Bild() {
    return (
        <View style={styles.container}>
            <Text style={styles.title}>Предметы в быту</Text>
            <Image style={styles.image} src='https://www.raten-kauf.com/pre/wp-content/uploads/sites/2/2020/04/Herd-auf-Raten-kaufen.png'/>
            <Text style={styles.wort}>Печка, печь, плита</Text>
        </View>
    );
}


const styles = StyleSheet.create({
    container: {
        marginTop: 45,
        gap: 15,
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
        fontSize: 16
    },
    wort: {
        color: '#eeeeee',
        fontSize: 45,
        width: '90%',
        lineHeight: 46,
        textTransform: 'lowercase'
    }
});

export default Bild;