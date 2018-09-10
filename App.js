/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {Platform, StyleSheet, Text, View, DeviceEventEmitter, Alert, Button, NativeModules} from 'react-native';

const NativeInteraction = NativeModules.NativeInteraction;

type Props = {};
export default class App extends Component<Props> {

  constructor(props) {
    super(props);
    this.state = {
        notice: '默认值',
    };
  }

  componentWillMount() {
      DeviceEventEmitter.addListener('EventInit', (msg) => {
          let receive = "EventInit: " + msg;
          console.log(receive);
          this.setState({notice: receive});
      });

      DeviceEventEmitter.addListener('EventLogin', (msg) => {
          let receive = "EventLogin: " + msg;
          console.log(receive);
          this.setState({notice: receive});
      });
  }

  transferIOS = () => {
    NativeInteraction.RNTransferIOS();
  }

  transferIOS1 = () => {
    NativeInteraction.RNTransferIOSWithParameter('{\'para1\':\'rndata1\',\'para2\':\'rndata2\'}');
  }

  transferIOS2 = () => {
    NativeInteraction.RNTransferIOSWithCallBack((data) => {
      this.setState({notice: data});
    });
  }

  transferIOS3 = () => {
    NativeInteraction.RNTransferIOSWithParameterAndCallBack('rndata1','rndata2').then(result =>{
      let jsonString = JSON.stringify(result);
      this.setState({notice: jsonString});
    }).catch(error=>{
    });
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>第一个React Native页面</Text>
        <Text style={styles.instructions}>{this.state.notice}</Text>
        <Button
          onPress={this.transferIOS}
          title="RN调用iOS（无回调无参数）"
          color="#841584"
          />
        <Button
          onPress={this.transferIOS1}
          title="RN调用iOS（有参数）"
          color="#841584"
          />
        <Button
          onPress={this.transferIOS2}
          title="RN调用iOS（有回调）"
          color="#841584"
          />
        <Button
          onPress={this.transferIOS3}
          title="RN调用iOS（有参数有回调）"
          color="#841584"
          />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
