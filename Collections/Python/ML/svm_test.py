import numpy as np
import matplotlib.pyplot as plt
from sklearn import svm
from sklearn.datasets import make_blobs
from sklearn.svm import SVC


# we create 40 separable points
X, y = make_blobs(n_samples=40, centers=2, random_state=6)

# fit the model, don't regularize for illustration purposes
clf = svm.SVC(kernel='linear', C=1000)
clf.fit(X, y)

plt.scatter(X[:, 0], X[:, 1], c=y, s=30, cmap=plt.cm.Paired)

# plot the decision function
ax = plt.gca()
xlim = ax.get_xlim()
ylim = ax.get_ylim()

# create grid to evaluate model
xx = np.linspace(xlim[0], xlim[1], 30)
yy = np.linspace(ylim[0], ylim[1], 30)
YY, XX = np.meshgrid(yy, xx)
xy = np.vstack([XX.ravel(), YY.ravel()]).T
Z = clf.decision_function(xy).reshape(XX.shape)

# plot decision boundary and margins
ax.contour(XX, YY, Z, colors='k', levels=[-1, 0, 1], alpha=0.5,
           linestyles=['--', '-', '--'])
# plot support vectors
ax.scatter(clf.support_vectors_[:, 0], clf.support_vectors_[:, 1], s=100,
           linewidth=1, facecolors='none', edgecolors='k')
plt.show()


import numpy as np
import math
def halfmoon(rad, width, dis, n_sample):

    data = np.random.rand(n_sample, 2) # create two half moon data
    labeledClass = np.zeros((n_sample, 1)) # include class 1 and class 2
    
    #radius = (rad - width / 2) + (width * np.random.rand())
    
    for i in range(0, int(n_sample / 2)):
        radius = (rad - width / 2) + (width * np.random.rand())
        theta = np.pi * np.random.rand() # rad
        data[i, 0] = radius * math.cos(theta)
        data[i, 1] = radius * math.sin(theta)
        labeledClass[i, 0] = 1
    
    for i in range(int(n_sample / 2), int(n_sample)):
        radius = (rad - width / 2) + (width * np.random.rand())
        theta = np.pi * np.random.rand() # rad
        data[i, 0] = radius * math.cos(-theta) + rad
        data[i, 1] = radius * math.sin(-theta) - dis
        labeledClass[i, 0] = -1
        
    return (data, labeledClass)


def plotSVM(data, labeledClass, cp, title, gamma='auto'):
    
    plt.scatter(data[:, 0], data[:, 1], cmap=plt.cm.Paired)
    
    # SVM model
    clf = SVC(kernel='rbf', C=cp)
    clf_fit = clf.fit(data, labeledClass)
    
    ax = plt.gca()
    
    # plot the decision function
    xlim = ax.get_xlim()
    ylim = ax.get_ylim()

    # create grid to evaluate model
    xx = np.linspace(xlim[0], xlim[1], 30)
    yy = np.linspace(ylim[0], ylim[1], 30)
    YY, XX = np.meshgrid(yy, xx)
    xy = np.vstack([XX.ravel(), YY.ravel()]).T
    Z = clf.decision_function(xy).reshape(XX.shape)

    # plot decision boundary and margins
    ax.contour(XX, YY, Z, colors='r', levels=[-1, 0, 1], alpha=0.5, 
               linestyles=['-', '--', '-'])
    ax.contourf(XX, YY, Z)

    # plot support vectors
    ax.scatter(clf.support_vectors_[:, 0], clf.support_vectors_[:, 1],
               linewidth=1, facecolors='none', edgecolors='k')
    ax.set_title(title)
    
    plt.show()
    
    return clf_fit

# generate dataset
N = 2000
Radius = 10
distance = -6
width = 6
(data, labeledClass) = halfmoon(Radius, width, distance, N)

# Put data into the SVM model
plotSVM(data, labeledClass, 0.1, 'SVM with rbf kernel (C=0.1)')
plotSVM(data, labeledClass, 1, 'SVM with rbf kernel (C=1)')
plotSVM(data, labeledClass, 10, 'SVM with rbf kernel (C=10)')
