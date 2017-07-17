"""

Linear Classifier.

- Need to document this stuff

"""

import numpy as np


def hinge_loss(feature_matrix, labels, theta, theta_0):
    """Find hinge loss given the feature matrix, labels and parameters.

    Args:
        feature_matrix - A numpy matrix describing the given data. Each row
            represents a single data point.
        labels - A numpy array where the kth element of the array is the
            correct classification of the kth row of the feature matrix.
        theta - A numpy array describing the linear classifier.
        theta_0 - A real valued number representing the offset parameter.

    Returns:
        A real number representing the hinge loss associated with the
        given dataset and parameters. This number should be the average hinge
        loss across all of the points in the feature matrix.

    """
    # Reshape the labels and theta:
    matrix_labels = np.array(labels)
    matrix_theta = np.array(theta)

    if(len(labels.shape) == 1):
        matrix_labels = np.array([labels])

    if(len(theta.shape) == 1):
        matrix_theta = np.array([theta])

    # product = feature * theta_transpose
    product = np.dot(feature_matrix, matrix_theta.T)

    # prediction = product + theta_0
    prediction = product + theta_0

    # result = 1 - prediction_transpose * labels
    result = 1 - np.multiply(prediction.T, matrix_labels)

    # hinge_loss = max(0, result)
    h_loss = np.maximum(0, result[0])

    # average hinge_loss
    avg_h_loss = h_loss.mean()

    return avg_h_loss


def single_step_perceptron(feature_vector, label,
                           current_theta, current_theta_0):
    """Single step perceptron.

    Args:
        feature_vector - A numpy array describing a single data point.
        label - The correct classification of the feature vector.
        current_theta - The current theta being used by the perceptron
            algorithm before this update.
        current_theta_0 - The current theta_0 being used by the perceptron
            algorithm before this update.
    Returns:
        A tuple where the first element is a numpy array with the value of
        theta after the current update has completed and the second element is
        a real valued number with the value of theta_0 after the current
        updated has completed.

    """
    # Assumption: feature vector and current_theta will be array (NOT matrix)

    result = np.dot(feature_vector, current_theta) + current_theta_0

    classify = 1 if result > 0 else -1

    updated_theta = current_theta
    updated_theta_0 = current_theta_0
    if classify != label:
        # Update theta:
        updated_theta = current_theta + label * feature_vector

        # Update theta_0:
        updated_theta_0 = current_theta_0 + label

    return (updated_theta, updated_theta_0)


def single_step_passive_aggressive(feature_vector, label, L,
                                   current_theta, current_theta_0):
    """Single step passive aggressive algorithm.

    Args:
        feature_vector - A numpy array describing a single data point.
        label - The correct classification of the feature vector.
        L - The lamba value being used to update the passive-aggressive
            algorithm parameters.
        current_theta - The current theta being used by the passive-aggressive
            algorithm before this update.
        current_theta_0 - The current theta_0 being used by the
            passive-aggressive algorithm before this update.

    Returns:
        A tuple where the first element is a numpy array with the value of
        theta after the current update has completed and the second element is
        a real valued number with the value of theta_0 after the current
        updated has completed.

    """
    # hinge loss
    loss = hinge_loss(np.array([feature_vector]), np.array([label]),
                      current_theta, current_theta_0)
    feature_magnitude = np.dot(feature_vector, feature_vector)

    eta = min(loss / feature_magnitude, 1.0 / L)

    updated_theta = current_theta + (eta * label) * feature_vector
    updated_theta_0 = current_theta_0 + eta * label

    return (updated_theta, updated_theta_0)


def perceptron(feature_matrix, labels, T):
    """Run the full perceptron algorithm on a given set of data.

    Runs T iterations through the data set, there is no need to worry about
    stopping early.

    Args:
        feature_matrix -  A numpy matrix describing the given data. Each row
            represents a single data point.
        labels - A numpy array where the kth element of the array is the
            correct classification of the kth row of the feature matrix.
        T - An integer indicating how many times the perceptron algorithm
            should iterate through the feature matrix.

    Returns: A tuple where the first element is a numpy array with the value of
    theta, the linear classification parameter, after T iterations through the
    feature matrix and the second element is a real number with the value of
    theta_0, the offset classification parameter, after T iterations through
    the feature matrix.

    """
    number_of_data_points = feature_matrix.shape[0]
    vector_length = feature_matrix.shape[1]

    final_theta = np.zeros(vector_length, dtype=float)
    final_theta_0 = 0.0

    for cycle in range(T):
        for index in range(number_of_data_points):
            feature_vector = feature_matrix[index]
            label = labels[index]

            updated_theta, updated_theta_0 = \
                single_step_perceptron(feature_vector, label,
                                       final_theta, final_theta_0)

            final_theta = updated_theta
            final_theta_0 = updated_theta_0

    return (final_theta, final_theta_0)


def average_perceptron(feature_matrix, labels, T):
    """Run the average perceptron algorithm on a given set of data.

    Runs T iterations through the data set, there is no need to worry about
    stopping early.

    Args:
        feature_matrix -  A numpy matrix describing the given data. Each row
            represents a single data point.
        labels - A numpy array where the kth element of the array is the
            correct classification of the kth row of the feature matrix.
        T - An integer indicating how many times the perceptron algorithm
            should iterate through the feature matrix.

    Returns: A tuple where the first element is a numpy array with the value of
    the average theta, the linear classification parameter, found after T
    iterations through the feature matrix and the second element is a real
    number with the value of the average theta_0, the offset classification
    parameter, found after T iterations through the feature matrix.

    """
    number_of_data_points = feature_matrix.shape[0]
    vector_length = feature_matrix.shape[1]

    final_theta = np.zeros(vector_length, dtype=float)
    final_theta_0 = 0.0

    sum_theta = 0.0
    sum_theta_0 = 0.0

    for cycle in range(T):
        for index in range(number_of_data_points):
            feature_vector = feature_matrix[index]
            label = labels[index]

            updated_theta, updated_theta_0 = \
                single_step_perceptron(feature_vector, label, final_theta,
                                       final_theta_0)

            final_theta = updated_theta
            final_theta_0 = updated_theta_0

            sum_theta += final_theta
            sum_theta_0 += final_theta_0

    avg_theta = sum_theta / (number_of_data_points * T)
    avg_theta_0 = sum_theta_0 / (number_of_data_points * T)

    return (avg_theta, avg_theta_0)


def average_passive_aggressive(feature_matrix, labels, T, L):
    """Run the average passive-agressive algorithm on a given set of data.

    Runs T iterations through the data set, there is no need to worry about
    stopping early.

    NOTE: Please use the previously implemented functions when applicable.
    Do not copy paste code from previous parts.

    Args:
        feature_matrix -  A numpy matrix describing the given data. Each row
            represents a single data point.
        labels - A numpy array where the kth element of the array is the
            correct classification of the kth row of the feature matrix.
        T - An integer indicating how many times the perceptron algorithm
            should iterate through the feature matrix.
        L - The lamba value being used to update the passive-agressive
            algorithm parameters.

    Returns: A tuple where the first element is a numpy array with the value of
    the average theta, the linear classification parameter, found after T
    iterations through the feature matrix and the second element is a real
    number with the value of the average theta_0, the offset classification
    parameter, found after T iterations through the feature matrix.

    """
    number_of_data_points = feature_matrix.shape[0]
    vector_length = feature_matrix.shape[1]

    final_theta = np.zeros(vector_length, dtype=float)
    final_theta_0 = 0.0

    sum_theta = 0.0
    sum_theta_0 = 0.0

    for cycle in range(T):
        for index in range(number_of_data_points):
            feature_vector = feature_matrix[index]
            label = labels[index]

            updated_theta, updated_theta_0 = \
                single_step_passive_aggressive(feature_vector, label, L,
                                               final_theta, final_theta_0)

            final_theta = updated_theta
            final_theta_0 = updated_theta_0

            sum_theta += final_theta
            sum_theta_0 += final_theta_0

    avg_theta = sum_theta / (number_of_data_points * T)
    avg_theta_0 = sum_theta_0 / (number_of_data_points * T)

    return (avg_theta, avg_theta_0)


def classify(feature_matrix, theta, theta_0):
    """classification.

    To classify a set of data points.

    Args:
        feature_matrix - A numpy matrix describing the given data. Each row
            represents a single data point.
                theta - A numpy array describing the linear classifier.
        theta - A numpy array describing the linear classifier.
        theta_0 - A real valued number representing the offset parameter.

    Returns: A numpy array of 1s and -1s where the kth element of the array
    is the predicted classification of the kth row of the feature matrix using
    the given theta and theta_0.

    """
    number_of_data = feature_matrix.shape[0]
    return_array = np.zeros(number_of_data, dtype=int)

    for index in range(number_of_data):
        value = np.dot(feature_matrix[index], theta) + theta_0
        if value <= 0:
            return_array[index] = -1
        else:
            return_array[index] = 1

    return return_array


def perceptron_accuracy(train_feature_matrix, val_feature_matrix,
                        train_labels, val_labels, T,
                        cutoff=None):
    """Train a linear classifier using the perceptron algorithm.

    With a given T value. The classifier is trained on the train data.
    The classifier's accuracy on the train and validation data is then returned

    Args:
        train_feature_matrix - A numpy matrix describing the training
            data. Each row represents a single data point.
        val_feature_matrix - A numpy matrix describing the training
            data. Each row represents a single data point.
        train_labels - A numpy array where the kth element of the array
            is the correct classification of the kth row of the training
            feature matrix.
        val_labels - A numpy array where the kth element of the array
            is the correct classification of the kth row of the validation
            feature matrix.
        T - The value of T to use for training with the perceptron algorithm.
        cutoff - A value that indicates whether we should save the theta and
            theta_0

    Returns: A tuple in which the first element is the (scalar) accuracy of the
    trained classifier on the training data and the second element is the
    accuracy of the trained classifier on the validation data.

    """
    final_theta, final_theta_0 = perceptron(train_feature_matrix,
                                            train_labels, T)

    train_result = classify(train_feature_matrix, final_theta, final_theta_0)
    val_result = classify(val_feature_matrix, final_theta, final_theta_0)

    train_accuracy = accuracy(train_result, train_labels)
    val_accuracy = accuracy(val_result, val_labels)

    if(cutoff is not None):
        if(val_accuracy > cutoff):
            save_result('perceptron_result', final_theta, final_theta_0)

    return (train_accuracy, val_accuracy)


def average_perceptron_accuracy(train_feature_matrix, val_feature_matrix,
                                train_labels, val_labels, T, cutoff=None):
    """Train a linear classifier using the average perceptron algorithm.

    With a given T value. The classifier is trained on the train data. The
    classifier's accuracy on the train and validation data is then returned.

    Args:
        train_feature_matrix - A numpy matrix describing the training
            data. Each row represents a single data point.
        val_feature_matrix - A numpy matrix describing the training
            data. Each row represents a single data point.
        train_labels - A numpy array where the kth element of the array
            is the correct classification of the kth row of the training
            feature matrix.
        val_labels - A numpy array where the kth element of the array
            is the correct classification of the kth row of the validation
            feature matrix.
        T - The value of T to use for training with the average perceptron
            algorithm.

    Returns: A tuple in which the first element is the (scalar) accuracy of the
    trained classifier on the training data and the second element is the
    accuracy of the trained classifier on the validation data.

    """
    final_theta, final_theta_0 = average_perceptron(train_feature_matrix,
                                                    train_labels, T)

    train_result = classify(train_feature_matrix, final_theta, final_theta_0)
    val_result = classify(val_feature_matrix, final_theta, final_theta_0)

    train_accuracy = accuracy(train_result, train_labels)
    val_accuracy = accuracy(val_result, val_labels)

    if(cutoff is not None):
        if(val_accuracy > cutoff):
            save_result('avg_perceptron_result', final_theta, final_theta_0)

    return (train_accuracy, val_accuracy)


def average_passive_aggressive_accuracy(
        train_feature_matrix, val_feature_matrix,
        train_labels, val_labels, T, L, cutoff=None):
    """Train a linear classifier using the average passive aggressive algorithm.

    With given T and L values. The classifier is trained on the train data.
    The classifier's accuracy on the train and validation data is then
    returned.

    Args:
        train_feature_matrix - A numpy matrix describing the training
            data. Each row represents a single data point.
        val_feature_matrix - A numpy matrix describing the training
            data. Each row represents a single data point.
        train_labels - A numpy array where the kth element of the array
            is the correct classification of the kth row of the training
            feature matrix.
        val_labels - A numpy array where the kth element of the array
            is the correct classification of the kth row of the validation
            feature matrix.
        T - The value of T to use for training with the average passive
            aggressive algorithm.
        L - The value of L to use for training with the average passive
            aggressive algorithm.

    Returns: A tuple in which the first element is the (scalar) accuracy of the
    trained classifier on the training data and the second element is the
    accuracy of the trained classifier on the validation data.

    """
    final_theta, final_theta_0 = average_passive_aggressive(
                                train_feature_matrix, train_labels, T, L)

    train_result = classify(train_feature_matrix, final_theta, final_theta_0)
    val_result = classify(val_feature_matrix, final_theta, final_theta_0)

    train_accuracy = accuracy(train_result, train_labels)
    val_accuracy = accuracy(val_result, val_labels)

    if(cutoff is not None):
        if(val_accuracy > cutoff):
            save_result('avg_PA_result', final_theta, final_theta_0)

    return (train_accuracy, val_accuracy)


def accuracy(preds, targets):
    """Given length-N vectors containing predicted and target labels.

    returns the percentage and number of correct predictions.

    """
    return (preds == targets).mean()


def save_result(file_name, final_theta, final_theta_0):
    """Save the result with in the file_name."""
    result = np.append(final_theta, final_theta_0)
    np.save(file_name, result)
