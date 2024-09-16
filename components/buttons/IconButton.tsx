import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';

type IconButtonProps = {
    icon: any,
    func: any
}

function IconButton({icon, func} : IconButtonProps) {
    const [hover, setHover] = useState(false);

    function ChangeHover(hover: boolean)  {
        setHover(hover);
    }

    return (
        <View style={[styles.container, hover ? styles.container_hover : ""]} onTouchStart={()=>ChangeHover(true)} onTouchEnd={()=>{func(); ChangeHover(false)}}>
            {icon}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        padding: 16,
        borderColor: 'white',
        borderWidth: 1,
        borderRadius: 10
    },
    container_hover: {
        backgroundColor: '#222'
    }
})

export default IconButton;