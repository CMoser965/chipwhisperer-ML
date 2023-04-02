import numpy as np
import tensorflow as tf
tf.compat.v1.logging.set_verbosity(tf.compat.v1.logging.ERROR)
from tensorflow import keras

import larq as lq
import larq_compute_engine as lce
import larq_zoo as lqz


model = tf.keras.models.load_model('./bnn.h5')

print("---------------------------------------\n\n\n\n")
model.summary()
print("---------------------------------------\n\n\n\n")

(x_train, y_train), (x_test, y_test) = keras.datasets.mnist.load_data()

test_images = x_train.reshape((60000, 28, 28, 1))

preds = model.predict(test_images)
print(preds[0:10])

for index, elem in enumerate(preds[0:100]):
    print("Model predicted", y_test[index], "as", np.argmax(elem), "with probability of", elem.max())

print(model.weights)