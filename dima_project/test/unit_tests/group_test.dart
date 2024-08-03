import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Group class test', () {
    test('Test Group constructor', () {
      Group group = Group(
        name: 'groupName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        lastMessage: null,
        categories: ['category1', 'category2'],
        members: ['admin'],
        requests: [],
      );
      expect(group.name, 'groupName');
      expect(group.description, 'description');
      expect(group.admin, 'admin');
      expect(group.imagePath, 'imagePath');
      expect(group.isPublic, true);
      expect(group.id, '123');
      expect(group.members, ['admin']);
      expect(group.requests, []);
      expect(group.categories, ['category1', 'category2']);
      expect(group.lastMessage, null);
    });
    test("Test toMap", () {
      Group group = Group(
        name: 'groupName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        lastMessage: null,
        categories: ['category1', 'category2'],
        members: ['admin'],
        requests: [],
      );
      Map<String, dynamic> groupMap = Group.toMap(group);
      expect(groupMap['groupId'], '123');
      expect(groupMap['groupName'], 'groupName');
      expect(groupMap['description'], 'description');
      expect(groupMap['groupImage'], 'imagePath');
      expect(groupMap['categories'], [
        {'value': 'category1'},
        {'value': 'category2'}
      ]);

      expect(groupMap['isPublic'], true);
    });
    test("Test fromSnapshot", () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('groups').doc('123').set({
        'groupId': '123',
        'groupName': 'groupName',
        'description': 'description',
        'groupImage': 'imagePath',
        'admin': 'admin',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'recentMessage': '',
        'members': ['admin'],
        'requests': [],
      });
      DocumentSnapshot documentSnapshot =
          await firestore.collection('groups').doc('123').get();
      Group group = Group.fromSnapshot(documentSnapshot);
      expect(group.id, '123');
      expect(group.name, 'groupName');

      expect(group.lastMessage, null);
      expect(group.admin, 'admin');
      expect(group.description, 'description');
      expect(group.imagePath, 'imagePath');
      expect(group.categories, ['category1', 'category2']);
      expect(group.isPublic, true);
      expect(group.members, ['admin']);
      expect(group.requests, []);
    });
    test('Test fromMap', () {
      Map<String, dynamic> groupMap = {
        'groupId': '123',
        'groupName': 'groupName',
        'description': 'description',
        'groupImage': 'imagePath',
        'categories': [
          'category1',
          'category2',
        ],
        'members': ['admin'],
        'requests': [],
        'isPublic': true,
        'admin': 'admin',
      };
      Group group = Group.fromMap(groupMap);
      expect(group.id, '123');
      expect(group.name, 'groupName');
      expect(group.admin, 'admin');
      expect(group.description, 'description');
      expect(group.imagePath, 'imagePath');
      expect(group.categories, ['category1', 'category2']);
      expect(group.members, ['admin']);
      expect(group.requests, []);
      expect(group.isPublic, true);
    });
  });
}
