import React from 'react';
import { StyleSheet, View } from 'react-native';

type IconButtonProps = {
    icon: any,
}

function IconButton({icon} : IconButtonProps) {
    return (
        <View>
            {icon}
        </View>
    );
}

const styles = StyleSheet.create

export default IconButton;