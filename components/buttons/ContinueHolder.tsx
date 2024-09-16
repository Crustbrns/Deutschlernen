import React from 'react';
import { Dimensions, StyleSheet, Text, View } from 'react-native';
import ContinueButton from './ContinueButton';

type ContinueHolderProps = {
    next: any;
    prev: any;
    direction: any;
}

function ContinueHolder({next, prev, direction} : ContinueHolderProps) {
    return (
        <View style={styles.holder}>
        <View style={styles.container}>
            <ContinueButton color={"#ec1c24"} rely={-1} direction={direction} text="Я не знаю это слово" func={()=>console.log('prev')}/>
            <View style={styles.divider}></View>
            <ContinueButton color={"#0eb24e"} rely={1} direction={direction} text="Я уже знаю это слово" func={()=>console.log('next')}/>
        </View>
        </View>
    );
}

const styles = StyleSheet.create({
    holder: {
        width: '100%',
        justifyContent: 'center',
        alignItems: 'center',
    },
    container: {
        flex: 1,
        // backgroundColor: 'red',
        flexDirection: 'row',
        justifyContent: 'space-between',
        gap: 20
    },
    divider: {
        backgroundColor: '#464646',
        width: 1,
        height: '100%'
    }
})

export default ContinueHolder;