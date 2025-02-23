import React, { FC, useState } from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import auth from '@react-native-firebase/auth';
import { GoogleSignin } from '@react-native-google-signin/google-signin';

import { Patterns } from '../../constants/Colors';
import LoginFailed from './LoginFailed';
import { WEB_CLIENT_ID } from '../../constants/Variables';

interface LoginProps {
    onRegister: () => void;
}

const Login: FC<LoginProps> = ({ onRegister }) => {
    const [loginFailed, setLoginFailed] = useState(false);

    GoogleSignin.configure({
        webClientId: WEB_CLIENT_ID,
    });

    const onLogin = async () => {
        try {
            // Start Google login process
            await GoogleSignin.hasPlayServices();
            const { idToken } = await GoogleSignin.signIn();

            // Create Firebase credentials
            const googleCredential = auth.GoogleAuthProvider.credential(idToken);

            // Sign in to Firebase
            await auth().signInWithCredential(googleCredential);

            console.log('User  signed in with Google');
        } catch (error) {
            console.error('Login failed:', error);
            setLoginFailed(true);

            // Remove failure message after 3 seconds
            setTimeout(() => {
                setLoginFailed(false);
            }, 3000);
 }
    };

    return (
        <View style={styles.container}>
            {loginFailed ? (
                <LoginFailed />
            ) : (
                <>
                    <TouchableOpacity style={styles.button} onPress={onLogin}>
                        <Text style={styles.buttonText}>Register</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={styles.button} onPress={onRegister}>
                        <Text style={styles.buttonText}>Login</Text>
                    </TouchableOpacity>
                </>
            )}
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Patterns.getColor('lightGray'), 
        justifyContent: 'center',
        alignItems: 'center',
    },
    button: {
        backgroundColor: Patterns.getColor('blue'),
        paddingHorizontal: 15,
        borderRadius: 5,
        height: 60,
        width: 400,
        marginTop: 20,
        justifyContent: 'center',
        alignItems: 'center',
    },
    buttonText: {
        color: Patterns.getColor('white'), 
        fontSize: 16,
        fontWeight: 'bold',
    },
});

export default Login;	import React, { FC } from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Patterns } from '../../constants/Colors';

const LoginFailed: FC = () => {
    return (
        <View style={styles.container}>
            <Text style={styles.text}>
                Login failed! Enter correct email or password.
            </Text>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: Patterns.getColor('lightGray'),
        justifyContent: 'center',
        alignItems: 'center',
    },
    text: {
        color: Patterns.getColor('red'),         fontSize: 18,
        fontWeight: 'bold',
        textAlign: 'center',
    },
});

export default LoginFailed;


import React, { useState, useEffect } from 'react';
import { View, Text, TouchableOpacity, TouchableWithoutFeedback, StyleSheet } from 'react-native';
import { CurrentSalary, statusList, myWallet } from '../databaseData/wallet'; 
import { Patterns } from '../constants/Colors';
import { hasPendingPayments } from './paymentUtils'; 

export default function TablePay() {
  const [pendingPayments, setPendingPayments] = useState(false);
  const [selectedPeriod, setSelectedPeriod] = useState('week'); 

  useEffect(() => {
    setPendingPayments(hasPendingPayments());
  }, []);

  const renderPaymentStatus = () => {
    const status = statusList.find(item => item.condition === pendingPayments);
    return status ? status.text : "Payments Up To Date";
  };

  const getButtonStyle = (period) => {
    return selectedPeriod === period
      ? { backgroundColor: Patterns.colors.grayishBlue, color: Patterns.colors.whiteIsh }
      : { backgroundColor: Patterns.colors.lightBlueGray, color: Patterns.colors.darkBlue };
  };

  return (
    <TouchableWithoutFeedback>
      <View style={styles.container}>
        <View style={styles.buttonContainer}>
          <TouchableOpacity 
            style={[styles.button, { backgroundColor: getButtonStyle('week').backgroundColor }]} 
            onPress={() => setSelectedPeriod('week')}
          >
            <Text style={[styles.buttonText, { color: getButtonStyle('week').color }]}>Week</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.button, { backgroundColor: getButtonStyle('month').backgroundColor }]} 
            onPress={() => setSelectedPeriod('month')}
          >
            <Text style={[styles.buttonText, { color: getButtonStyle('month').color }]}>Month</Text>
          </TouchableOpacity>

          <TouchableOpacity 
            style={[styles.button, { backgroundColor: getButtonStyle('year').backgroundColor }]} 
            onPress={() => setSelectedPeriod('year')}
          >
            <Text style={[styles.buttonText, { color: getButtonStyle('year').color }]}>Year</Text>
          </TouchableOpacity>
        </View>
        <Text>{renderPaymentStatus()}</Text>
        <CurrentSalary textColor={Patterns.getSalaryState(myWallet)} />
      </View>
    </TouchableWithoutFeedback>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingTop: 20,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
    paddingTop: 20,
  },
  button: {
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
  },
  buttonText: {
    fontSize: 16,
  },
});	import studentData from '../data/students.json';
import { Patterns } from '../constants/Colors';

const Wallet = {
  paymentsOverdue: studentData.payment?.frequency !== 'up to date',
  isPaid: studentData.payment?.type === 'Pix',
  Salary: {
    paymentsUpToDate: 'up to date',
    paymentsOverdue: 'overdue',
  },
};

const handleDataError = (data, fieldName) => {
  if (!data) {
    console.error(`Error: Missing or invalid data for ${fieldName}`);
  }
};

const statusList = [
  {
    condition: Wallet.paymentsOverdue === true,
    text: 'Payments Overdue',
  },
  {
    condition: Wallet.paymentsOverdue === false,
    text: 'Payments Up To Date',
  },
];

const getStatusMessage = () => {
  if (!studentData || !studentData.payment) {
    handleDataError(studentData, 'studentData');
    return 'Unable to fetch status';
  }

  const walletStatus = statusList.find((item) => item.condition);

  if (!walletStatus) {
    return 'Unknown Status';
  }

  return walletStatus.text;
};

const getSalaryColor = () => {
  if (!Patterns || !Patterns.colors) {
    return 'defaultColor';
  }

  return Wallet.paymentsOverdue ? Patterns.colors.red : Patterns.colors.blue;
};

const handleFirebaseError = (error) => {
  if (error instanceof Error) {
    console.error('Firebase Error:', error.message);
  } else {
    console.error('Unknown Firebase Error:', error);
  }
};

const fetchStudentDataFromFirebase = async () => {
  try {
    const data = await firebase.firestore().collection('students').doc('studentId').get();
    
    if (!data.exists) {
      console.error('Error: No student data found.');
      return;    
    }
    
    console.log('Fetched student data:', data.data());
  } catch (error) {
    handleFirebaseError(error);
  }
};

const processPaymentTransaction = async () => {
  try {
    const result = await firebase.functions().httpsCallable('processPayment')();
    console.log('Payment processed:', result);
  } catch (error) {
    console.error('Error processing payment:', error);
  }
};

export default Wallet;

export {
  handleDataError,
  statusList,
  getStatusMessage,
  getSalaryColor,
  handleFirebaseError,
  fetchStudentDataFromFirebase,
  processPaymentTransaction,
};


import React, { useState, useEffect } from 'react';
import { View, Text, TouchableWithoutFeedback } from 'react-native';
import { CurrentSalary, hasPendingPayments, myWallet } from '../databaseData/wallet';
import { Patterns } from '../constants/Colors';

export default function ShowPayment() {
  const [pendingPayments, setPendingPayments] = useState(false);

  useEffect(() => {
    setPendingPayments(hasPendingPayments());
  }, []);

  const statusList = [
    { condition: true, text: "Payments Overdue" },
    { condition: false, text: "Payments Up To Date" }
  ];

  const renderPaymentStatus = () => {
    const status = statusList.find(item => item.condition === pendingPayments);
    return status ? status.text : "Payments Up To Date";
  };

  return (
    <TouchableWithoutFeedback>
      <View>
        <Text>{renderPaymentStatus()}</Text>
        <CurrentSalary textColor={Patterns.getSalaryState(myWallet)} />
      </View>
    </TouchableWithoutFeedback>
  );
}


import { myWallet } from '../databaseData/wallet';

const Patterns = {
  colors: {
    brightBlue: '#3498DB',
    paleBlue: '#67888A',
    darkBlue: '#2C3E50',
    paleRed: '#E74C3C',
    lightGray: '#CCD9DC',
    whiteIsh: '#ECF0F1',
    grayIsh: '#ddd',
    grayishBlue: '#AAB8C2',
    lightBlueGray: '#B7C9D9',
    blue: '#007BFF',
    red: '#FF0000',
  },

  getColor: (key) => {
    const color = Patterns.colors[key];
    if (!color) {
      console.warn(`Color with key '${key}' not found.`);
      return Patterns.colors.whiteIsh;
    }
    return color;
  },

  getSalaryState: (myWallet) => {
    if (!myWallet) {
      return Patterns.colors.lightGray;
    }

    if (myWallet.paymentsOverdue) {
      return Patterns.colors.red;
    }

    return myWallet.isPaid ? Patterns.colors.blue : Patterns.colors.whiteIsh;
  },
};

export { Patterns };



import React, { useState } from 'react';
import { View, TextInput, Button, Text, Picker } from 'react-native';
import ButtonsMenu from '../sections/buttonsMenu';
import ScrollableTable from '../sections/scrollableTable';
import { getStudentHelpers } from './StudentHelpers';
import { db, collection, addDoc } from '../firebaseConfig'; 
import { Patterns } from '../constants/Colors';

const { createNewStudent } = getStudentHelpers();

const buttonData = [
  {
    key: '1', title: 'name', submenu: [
      { key: '1.1', title: 'name' },
      { key: '1.2', title: 'phone' },
      { key: '1.3', title: 'cpf' },
      { key: '1.4', title: 'pay' },
      { key: '1.5', title: 'overdue pay' },
      { key: '1.6', title: 'incoming pay' },
      { key: '1.7', title: 'status' },
    ]
  },
];

const StudentDatabase = () => {
  const [activeStudentMenuKey, setActiveStudentMenuKey] = useState('');
  const [tableData, setTableData] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [newStudent, setNewStudent] = useState(null);
  const [studentForm, setStudentForm] = useState({
    name: '',
    age: '',
    status: 'active',
    level: 'A1',
    paymentType: 'Pix',
    paymentFrequency: 'monthly',
    paymentAmount: '',
    cpf: '',
    phoneNumber: '',
    missedClasses: '',
    beginDate: new Date(),
  });

  const handleUpdateStudent = (updatedStudent) => {
    setTableData(prevData =>
      prevData.map(student =>
        student.cpf === updatedStudent.cpf ? updatedStudent : student
      )
    );
  };

  const handleViewStudent = (cpf) => {
    const selectedStudent = tableData.find(student => student.cpf === cpf);
    if (selectedStudent) {
      setNewStudent(selectedStudent);
    }
  };

  const handleButtonPress = (key) => {
    setActiveStudentMenuKey(key);
  };

  const handleRowPress = (student) => {
    handleViewStudent(student.cpf);
  };

  const handleNewButtonPress = async () => {
    const { name, age, status, level, paymentType, paymentFrequency, paymentAmount, cpf, phoneNumber, missedClasses, beginDate } = studentForm;

    if (name && age && paymentAmount && cpf && phoneNumber) {
      const newStudent = createNewStudent({
        name,
        age: parseInt(age),
        status,
        level,
        courses: [],
        paymentType,
        paymentFrequency,
        paymentAmount: parseFloat(paymentAmount),
        cpf,
        phoneNumber,
        missedClasses: parseInt(missedClasses),
        beginDate: new Date(beginDate),
      });

      try {
        const docRef = await addDoc(collection(db, 'students'), newStudent);
        setTableData(prevData => [...prevData, newStudent]);
        setNewStudent(newStudent);
      } catch (e) {
        console.error('Error adding document: ', e);
      }
    } else {
      alert('Please fill in all required fields.');
    }
  };

  const handleSearchButtonPress = () => {
    const filteredData = tableData.filter(student =>
      student.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      student.cpf.includes(searchQuery)
    );
    setTableData(filteredData);
  };

  const handleSearchChange = (text) => {
    setSearchQuery(text);
  };

  const handleInputChange = (field, value) => {
    setStudentForm(prevState => ({
      ...prevState,
      [field]: value,
    }));
  };

  return (
    <View style={{ flex: 1, paddingBottom: 10 }}>
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', padding: 10 }}>
        <Button title="New" onPress={handleNewButtonPress} />
        <TextInput
          style={{ borderWidth: 1, borderColor: Patterns.grayIsh, padding: 5, flex: 1 }}
          placeholder="Search by name or CPF"
          value={searchQuery}
          onChangeText={handleSearchChange}
        />
        <Button title="Search" onPress={handleSearchButtonPress} />
      </View>

      <ButtonsMenu buttonData={buttonData} onPressButton={handleButtonPress} currentKey={activeStudentMenuKey} />

      <ScrollableTable
        tableData={tableData}
        onRowPress={handleRowPress}
        columns={['name', 'age', 'cpf']}
      />

      <View style={{ padding: 10 }}>
        <Text>Create New Student</Text>
        <TextInput
          placeholder="Name"
          value={studentForm.name}
          onChangeText={text => handleInputChange('name', text)}
        />
        <TextInput
          placeholder="Age"
          value={studentForm.age}
          onChangeText={text => handleInputChange('age', text)}
          keyboardType="numeric"
        />
        <TextInput
          placeholder="CPF"
          value={studentForm.cpf}
          onChangeText={text => handleInputChange('cpf', text)}
        />
        <TextInput
          placeholder="Phone Number"
          value={studentForm.phoneNumber}
          onChangeText={text => handleInputChange('phoneNumber', text)}
        />
        <TextInput
          placeholder="Payment Amount"
          value={studentForm.paymentAmount}
          onChangeText={text => handleInputChange('paymentAmount', text)}
          keyboardType="numeric"
        />
        <Picker
          selectedValue={studentForm.paymentType}
          onValueChange={itemValue => handleInputChange('paymentType', itemValue)}>
          <Picker.Item label="Pix" value="Pix" />
          <Picker.Item label="Credit" value="Credit" />
          <Picker.Item label="Debit" value="Debit" />
        </Picker>
        <Picker
          selectedValue={studentForm.paymentFrequency}
          onValueChange={itemValue => handleInputChange('paymentFrequency', itemValue)}>
          <Picker.Item label="Monthly" value="monthly" />
          <Picker.Item label="Weekly" value="weekly" />
          <Picker.Item label="Per Class" value="per class" />
        </Picker>
        <Button title="Create Student" onPress={handleNewButtonPress} />
      </View>

      {newStudent && (
        <View style={{ padding: 10 }}>
          <Text>Viewing Student Details:</Text>
          <Text>Name: {newStudent.name}</Text>
          <Text>Age: {newStudent.age}</Text>
          <Text>CPF: {newStudent.cpf}</Text>
          <Button
            title="Edit Student"
            onPress={() =>
              handleUpdateStudent({
                ...newStudent,
                name: `${newStudent.name} (Updated)`
              })
            }
          />
        </View>
      )}
    </View>
  );
};

export default StudentDatabase;


import React, { useState } from 'react';
import { View, TextInput, Button, FlatList, StyleSheet } from 'react-native';
import { getStudentHelpers } from './StudentHelpers';
import { Patterns } from '../constants/Colors';

const { Level } = getStudentHelpers();

const StudentLevels = () => {
  const [students, setStudents] = useState([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredStudents, setFilteredStudents] = useState([]);

  const handleSearchButtonPress = () => {
    setFilteredStudents(
      students.filter(student =>
        student.name.toLowerCase().includes(searchQuery.toLowerCase())
      )
    );
  };

  const handleSearchChange = (text) => {
    setSearchQuery(text);
  };

  const handleSortAsc = () => {
    setFilteredStudents(prev =>
      [...prev].sort((a, b) => a.name.localeCompare(b.name))
    );
  };

  const handleSortDesc = () => {
    setFilteredStudents(prev =>
      [...prev].sort((a, b) => b.name.localeCompare(a.name))
    );
  };

  const handleFilterByCategory = (category) => {
    setFilteredStudents(
      students.filter(student => {
        if (category === 'A') {
          return student.level === Level.A1 || student.level === Level.A2;
        } else if (category === 'B') {
          return student.level === Level.B1 || student.level === Level.B2;
        } else if (category === 'C') {
          return student.level === Level.C1 || student.level === Level.C2;
        }
        return false;
      })
    );
  };

  const handleUpdateStudentLevel = (name, newLevel) => {
    setStudents(prev =>
      prev.map(student =>
        student.name === name ? { ...student, level: newLevel } : student
      )
    );
    setFilteredStudents(prev =>
      prev.map(student =>
        student.name === name ? { ...student, level: newLevel } : student
      )
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.searchContainer}>
        <TextInput
          style={styles.searchInput}
          placeholder="Search by name"
          value={searchQuery}
          onChangeText={handleSearchChange}
        />
        <Button title="Search" onPress={handleSearchButtonPress} />
      </View>

      <View style={styles.buttonContainer}>
        <Button title="ASC" onPress={handleSortAsc} />
        <Button title="DESC" onPress={handleSortDesc} />
        <Button title="Category A" onPress={() => handleFilterByCategory('A')} />
        <Button title="Category B" onPress={() => handleFilterByCategory('B')} />
        <Button title="Category C" onPress={() => handleFilterByCategory('C')} />
      </View>

      <FlatList
        data={filteredStudents}
        keyExtractor={(item, index) => index.toString()}
        renderItem={({ item }) => (
          <View style={styles.listItem}>
            <Text>{item.name}</Text>
            <Text>{item.level}</Text>
            <TextInput
              style={styles.levelInput}
              value={item.level}
              onChangeText={newLevel => handleUpdateStudentLevel(item.name, newLevel)}
            />
          </View>
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 10,
  },
  searchContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  searchInput: {
    borderWidth: 1,
    borderColor: Patterns.grayIsh,
    padding: 5,
    flex: 1,
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 10,
  },
  listItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    padding: 10,
    borderBottomWidth: 1,
    borderColor: Patterns.grayIsh,
  },
  levelInput: {
    borderWidth: 1,
    borderColor: Patterns.grayIsh,
    padding: 5,
    width: 100,
  },
});

export default StudentLevels;	const express = require('express');
const admin = require('firebase-admin');
const app = express();
const PORT = 5000;

const serviceAccount = require('./path/to/your/firebase-service-account-key.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://your-project-id.firebaseio.com',
});

const db = admin.firestore();

app.use(express.json());

app.post('/saveStudent', async (req, res) => {
  const newStudent = req.body;
  try {
    const studentRef = db.collection('students').doc();
    await studentRef.set(newStudent);
    res.status(200).json({ message: 'Student saved successfully!' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to save student data.' });
  }
});

app.get('/getStudents', async (req, res) => {
  try {
    const snapshot = await db.collection('students').get();
    const students = snapshot.docs.map(doc => doc.data());
    res.status(200).json({ students });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch students.' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});


import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Platform } from 'react-native';
import * as Updates from 'expo-updates';
import { Patterns } from '../../constants/Colors';

const Details = () => {
  const { version, author, license } = Updates.manifest?.expo || {};

  return (
    <View style={styles.container}>
      <Text style={styles.text}>
        {author} | {license}
      </Text>
      <Text style={styles.versionText}>V {version}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    padding: 10,
    marginTop: Platform.OS === 'ios' ? 50 : 30,
  },
  text: {
    fontSize: 18,
    fontWeight: 'bold',
    color: Patterns.getColor('paleBlue'),
  },
  versionText: {
    fontSize: 16,
    color: Patterns.getColor('paleBlue'),
  },
});

export default Details;

import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import auth from '@react-native-firebase/auth';
import { useNavigation } from '@react-navigation/native';
import { Patterns } from '../../constants/Colors';
import Details from '../../constants/Details'; 

const Menu = () => {
  const navigation = useNavigation();

  const handleLogoff = async () => {
    try {
      await auth().signOut();
      navigation.reset({
        index: 0,
        routes: [{ name: 'Login' }],
      });
    } catch (error) {
      console.error('Logoff error:', error);
    }
  };

  const handleAbout = () => {
    navigation.navigate('About'); 
  };

  const handleSupport = () => {
    navigation.navigate('Support');
  };

  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.button} onPress={handleAbout}>
        <Text style={styles.buttonText}>About</Text>
      </TouchableOpacity>

      <TouchableOpacity style={styles.button} onPress={handleSupport}>
        <Text style={styles.buttonText}>Support</Text>
      </TouchableOpacity>

      <TouchableOpacity style={[styles.button, styles.logoffButton]} onPress={handleLogoff}>
        <Text style={styles.buttonText}>Logoff</Text>
      </TouchableOpacity>

      <View style={styles.detailsContainer}>
        <Details />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Patterns.getColor('blue'),
    justifyContent: 'center',
    alignItems: 'center',
  },
  button: {
    backgroundColor: Patterns.getColor('white'),
    paddingHorizontal: 20,
    borderRadius: 5,
    height: 50,
    width: 300,
    marginTop: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  logoffButton: {
    backgroundColor: Patterns.getColor('red'),
  },
  buttonText: {
    color: Patterns.getColor('black'),
    fontSize: 16,
    fontWeight: 'bold',
  },
  detailsContainer: {
    marginTop: 30,
    alignItems: 'center',
  },
});

export default Menu;

import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Patterns } from '../constants/Colors';

const About = () => {
  const navigation = useNavigation();

  const handleBackPress = () => {
    navigation.goBack();
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerText}>@snoozleEmily | the unlicensed</Text>
        <Text style={styles.version}>V 1.0</Text>
      </View>
      <Text style={styles.title}>THIS</Text>
      <Text style={styles.subtitle}>UNIVERSITY PROJECT</Text>
      <Text style={styles.content}>
        ADDRESSES KEY CHALLENGES FACED IN PRIVATE EDUCATIONAL MANAGEMENT, 
        INCLUDING DISORGANIZATION IN STUDENT MANAGEMENT, OVERDUE PAYMENT REMINDERS, 
        HIGH DROPOUT RATES, AND DIFFICULTIES IN SUPPORTING BEGINNER STUDENTS AND 
        MOTIVATING OLDER LEARNERS.
        {'\n\n'}
        ALIGNED WITH <Text style={styles.highlight}>UN GOALS FOR QUALITY EDUCATION AND DECENT WORK</Text>, 
        THE APP WAS DEVELOPED USING REACT NATIVE, TYPESCRIPT, AND FIREBASE TO STREAMLINE STUDENT DATA MANAGEMENT. 
        IT ENABLES SIMPLIFIED CRUD OPERATIONS, TRACKS PAYMENTS, PROVIDES REMINDERS, AND GENERATES REPORTS TO HELP PERSONALIZE TEACHING STRATEGIES.
      </Text>
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.button} onPress={handleBackPress}>
          <Text style={styles.buttonText}>Back</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Patterns.lightGray,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    width: '100%',
    marginBottom: 20,
  },
  headerText: {
    fontSize: 14,
    color: Patterns.grayIsh,
  },
  version: {
    fontSize: 12,
    color: Patterns.grayIsh,
  },
  title: {
    fontSize: 36,
    color: Patterns.darkBlue,
    fontWeight: 'bold',
    textAlign: 'left',
    alignSelf: 'stretch',
    marginBottom: 10,
  },
  subtitle: {
    fontSize: 36,
    color: Patterns.brightBlue,
    fontWeight: 'bold',
    textAlign: 'left',
    alignSelf: 'stretch',
    marginBottom: 20,
  },
  content: {
    fontSize: 14,
    color: Patterns.darkBlue,
    fontWeight: 'bold',
    textAlign: 'justify',
    letterSpacing: 1,
    marginBottom: 20,
  },
  highlight: {
    color: Patterns.brightBlue,
    fontWeight: 'bold',
  },
  buttonContainer: {
    marginTop: 20,
    width: '100%',
    alignItems: 'center',
  },
  button: {
    backgroundColor: Patterns.grayIsh,
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 4,
  },
  buttonText: {
    color: Patterns.darkBlue,
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default About;


import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { Patterns } from '../../constants/Colors';

const Support = () => {
  const navigation = useNavigation();

  const handleBackPress = () => {
    navigation.goBack();
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.headerText}>@snoozleEmily | the unlicensed</Text>
        <Text style={styles.version}>V 1.0</Text>
      </View>
      <Text style={styles.content}>
        Please reach out through the e-mail
        {'\n'}
        <Text style={styles.email}>snoozleemily@gmail.com</Text>
      </Text>
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.button} onPress={handleBackPress}>
          <Text style={styles.buttonText}>Back</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Patterns.lightGray,
    padding: 20,
    justifyContent: 'center',
    alignItems: 'center',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    width: '100%',
    marginBottom: 20,
  },
  headerText: {
    fontSize: 14,
    color: Patterns.grayIsh,
  },
  version: {
    fontSize: 12,
    color: Patterns.grayIsh,
  },
  content: {
    fontSize: 14,
    color: Patterns.darkBlue,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
  },
  email: {
    color: Patterns.brightBlue,
    fontWeight: 'bold',
    textDecorationLine: 'underline',
  },
  buttonContainer: {
    marginTop: 20,
    width: '100%',
    alignItems: 'center',
  },
  button: {
    backgroundColor: Patterns.grayIsh,
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
    shadowColor: '#000',
    shadowOpacity: 0.1,
    shadowOffset: { width: 0, height: 2 },
    shadowRadius: 4,
  },
  buttonText: {
    color: Patterns.darkBlue,
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default Support;



const StudentOverview: React.FC<{ studentJson: any }> = ({ studentJson }) => {
    const navigation = useNavigation();
    const [student, setStudent] = useState<getStudentHelpers.Student | null>(null);
    const [currentDate, setCurrentDate] = useState<string>('');
    const [loading, setLoading] = useState(true);
    const [isEditing, setIsEditing] = useState(false);
    const [editedNotes, setEditedNotes] = useState(notesData);
  
    useEffect(() => {
      const fetchData = async () => {
        const today = new Date().toLocaleDateString();
        setCurrentDate(today);
  
        try {
          const cachedStudent = await AsyncStorage.getItem('studentData');
          if (cachedStudent) {
            const studentData = JSON.parse(cachedStudent);
            setStudent(studentData);
            setLoading(false);
          } else {
            const transformedStudent = getStudentHelpers.jsonToStudent(studentJson);
            setStudent(transformedStudent);
            await AsyncStorage.setItem('studentData', JSON.stringify(transformedStudent));
            setLoading(false);
          }
        } catch (error) {
          console.error("Error fetching student data from cache:", error);
          setLoading(false);
        }
      };
  
      fetchData();
    }, [studentJson]);
  
    const handleBackPress = () => {
      navigation.goBack();
    };
  
    const handleEditStudent = () => {
      setIsEditing(!isEditing);
    };
  
    const handleNoteEdit = (index: number, newContent: string) => {
      const updatedNotes = [...editedNotes];
      updatedNotes[index].content = newContent;
      setEditedNotes(updatedNotes);
    };
  
    const handleSaveNotes = async () => {
    try {
      await AsyncStorage.setItem('notesData', JSON.stringify(editedNotes));
      console.log('Notes saved successfully');
    } catch (error) {
      console.error('Error saving notes to AsyncStorage:', error);
    }
  };
  
  
    if (loading) {
      return (
        <View style={styles.loadingContainer}>
          <LottieView
            source={require('../assets/loading.json')}
            autoPlay
            loop
            style={styles.loadingAnimation}
          />
        </View>
      );
    }
  
    return (
      <ScrollView contentContainerStyle={styles.container}>
        <View style={styles.header}>
          <Text style={styles.headerText}>
            {/* Ensure student is not null */}
            {student?.age} years old • {currentDate}
          </Text>
          {isEditing ? (
            <TextInput
              style={styles.inputField}
              value={student?.name || ''}
              onChangeText={(text) => setStudent((prevStudent) => prevStudent ? { ...prevStudent, name: text } : prevStudent)}
            />
          ) : (
            <Text style={styles.name}>{student?.name}</Text>
          )}
          <Text style={styles.status}>{student?.status}</Text>
        </View>
        <View style={styles.contactInfo}>
          {isEditing ? (
            <>
              <TextInput
                style={styles.inputField}
                value={student?.cpf || ''}
                onChangeText={(text) => setStudent((prevStudent) => prevStudent ? { ...prevStudent, cpf: text } : prevStudent)}
              />
              <TextInput
                style={styles.inputField}
                value={student?.phoneNumber || ''}
                onChangeText={(text) => setStudent((prevStudent) => prevStudent ? { ...prevStudent, phoneNumber: text } : prevStudent)}
              />
            </>
          ) : (
            <>
              <Text style={styles.contactText}>{student?.cpf}</Text>
              <Text style={styles.contactText}>{student?.phoneNumber}</Text>
            </>
          )}
        </View>
        <View style={styles.salaryInfo}>
          <Text style={styles.salaryText}>R$ {student?.payment?.amount}</Text>
          <Text style={styles.salaryText}>Pay day on {student?.payment?.day}</Text>
        </View>
        <View style={styles.notes}>
          {editedNotes.map((note, index) => (
            <View key={index} style={styles.noteContainer}>
              <Text style={styles.noteTitle}>NOTE {note.date}</Text>
              {note.isEditing ? (
                <TextInput
                  style={styles.inputField}
                  value={note.content}
                  onChangeText={(text) => handleNoteEdit(index, text)}
                />
              ) : (
                <View style={styles.generalNotes}>
                  <Text style={styles.noteText}>{note.content}</Text>
                </View>
              )}
              <TouchableOpacity
                style={styles.editNoteButton}
                onPress={() => {
                  const updatedNotes = [...editedNotes];
                  updatedNotes[index].isEditing = !updatedNotes[index].isEditing;
                  setEditedNotes(updatedNotes);
                }}
              >
                <Text style={styles.editNoteText}>
                  {note.isEditing ? 'Save' : 'Edit'}
                </Text>
              </TouchableOpacity>
            </View>
          ))}
          <TouchableOpacity style={styles.newNote} onPress={handleSaveNotes}>
            <Text style={styles.newNoteText}>+ Save Notes</Text>
          </TouchableOpacity>
        </View>
        <TouchableOpacity style={styles.backButton} onPress={handleBackPress}>
          <Text style={styles.backButtonText}>Back</Text>
        </TouchableOpacity>
  
        <TouchableOpacity style={styles.editButton} onPress={handleEditStudent}>
          <Text style={styles.editButtonText}>{isEditing ? 'Save Student Info' : 'Edit Student Info'}</Text>
        </TouchableOpacity>
      </ScrollView>
    );
  };
  
  // Continues on the right part of the table >>>>>
  
      const styles = StyleSheet.create({
    container: {
      flexGrow: 1,
      backgroundColor: Patterns.lightGray,
      padding: 10,
    },
    header: {
      backgroundColor: Patterns.whiteIsh,
      alignItems: 'center',
      paddingVertical: 20,
      marginBottom: 10,
      borderRadius: 10,
    },
    headerText: {
      fontSize: 12,
      color: Patterns.grayIsh,
      fontStyle: 'italic',
    },
    name: {
      fontSize: 24,
      color: Patterns.darkBlue,
      fontWeight: 'bold',
    },
    status: {
      color: Patterns.brightBlue,
      fontWeight: 'bold',
    },
    inputField: {
      fontSize: 18,
      borderBottomWidth: 1,
      borderColor: Patterns.grayIsh,
      width: '80%',
      textAlign: 'center',
      marginVertical: 5,
    },
    contactInfo: {
      backgroundColor: Patterns.paleBlue,
      flexDirection: 'row',
      justifyContent: 'space-around',
      paddingVertical: 10,
      borderRadius: 10,
      marginBottom: 10,
    },
    contactText: {
      fontSize: 14,
      color: Patterns.darkBlue,
    },
    salaryInfo: {
      backgroundColor: Patterns.brightBlue,
      flexDirection: 'row',
      justifyContent: 'space-between',
      paddingVertical: 10,
      paddingHorizontal: 20,
      borderRadius: 10,
      marginBottom: 10,
    },
    salaryText: {
      fontSize: 18,
      color: Patterns.whiteIsh,
      fontWeight: 'bold',
    },
    notes: {
      backgroundColor: Patterns.whiteIsh,
      padding: 10,
      borderRadius: 10,
    },
    noteContainer: {
      marginBottom: 20,
    },
    noteTitle: {
      fontSize: 16,
      color: Patterns.darkBlue,
      fontWeight: 'bold',
      marginBottom: 10,
    },
    generalNotes: {
      backgroundColor: Patterns.paleBlue,
      padding: 10,
      borderRadius: 5,
    },
    noteText: {
      fontSize: 14,
      color: Patterns.darkBlue,
    },
    newNote: {
      alignItems: 'center',
      marginTop: 10,
    },
    newNoteText: {
      fontSize: 18,
      color: Patterns.brightBlue,
      fontWeight: 'bold',
    },
    backButton: {
      backgroundColor: Patterns.paleBlue,
      alignItems: 'center',
      paddingVertical: 10,
      marginTop: 20,
      borderRadius: 5,
    },
    backButtonText: {
      fontSize: 18,
      color: Patterns.brightBlue,
      fontWeight: 'bold',
    },
    loadingContainer: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center',
      backgroundColor: Patterns.lightGray,
    },
    loadingAnimation: {
      width: 150,
      height: 150,
    },
    editButton: {
      backgroundColor: Patterns.brightBlue,
      alignItems: 'center',
      paddingVertical: 10,
      marginTop: 20,
      borderRadius: 5,
    },
    editButtonText: {
      fontSize: 18,
      color: Patterns.whiteIsh,
      fontWeight: 'bold',
    },
    editNoteButton: {
      backgroundColor: Patterns.grayIsh,
      padding: 10,
      marginTop: 10,
      borderRadius: 5,
    },
    editNoteText: {
      fontSize: 14,
      color: Patterns.brightBlue,
      fontWeight: 'bold',
    },
  });
  
  export default StudentOverview;
  
  