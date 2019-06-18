import React, { Component } from 'react';
import { StyleSheet, Text, View } from 'react-native';

export default class InfoItem extends Component {
  render () {
    const { index, item } = this.props;
    return (
      <View style={styles.container}>
        <Text style={styles.name}>{item.enable ? item.meat : 'Probe ' + index}</Text>
        <View style={styles.mainView}>
          <View style={styles.subView}>
            <View style={styles.circleView}>
              <Text style={styles.circleText}>{item.enable ? item.restTime : 'N.A.'}</Text>
            </View>
            <Text style={styles.bottomText}>Time</Text>
          </View>
          <View style={styles.subView}>
            <View style={styles.circleView}>
              <Text style={styles.circleText}>{item.enable ? item.value : 'N.A.'}</Text>
            </View>
            <Text style={styles.bottomText}>Temperature</Text>
          </View>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'column',
  },
  name: {
    fontSize: 20,
    color: '#000000',
    marginBottom: 20,
  },
  mainView: {
    flexDirection: 'row',
    paddingVertical: 8
  },
  subView: {
    flexDirection: 'column',
  },
  circleView: {
    width: 50,
    height: 50,
    borderColor: '#000000',
    borderWidth: 1,
    borderRadius: 30,
    marginRight: 16 ,
    justifyContent: 'center',
    alignItems: 'center',
  },
  circleText: {
    fontSize: 12,
    color: '#000000',
  },
  bottomText: {
    fontSize: 10,
    color: '#000000',
    marginTop: 16,
    textAlign: 'center',
  },
});