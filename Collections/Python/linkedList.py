#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 14 19:26:59 2021

@author: mingchiehhung
"""

# create node (haven't linked yet)
class Node:
    # initial constructor
    def __init__(self, data):
        self.data = data
        self.next = None
        
class LinkedList:
    def __init__(self):
        self.head = None
        
    def print_List(self):
        temp = self.head
        while(temp):
            print(temp.data)
            temp = temp.next
            
if __name__ == '__main__':
    # start a list from empty list
    ini_list = LinkedList()
    
    ini_list.head = Node(1)
    second = Node(2)
    third = Node(3)
    
    # link each node
    ini_list.head.next = second
    second.next = third
    
    ini_list.print_List()
    
    