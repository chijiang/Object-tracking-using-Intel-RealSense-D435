model = importKerasLayers('my_model.h5', 'ImportWeights', true);
model = removeLayers(model, 'Reshape_1');
model = removeLayers(model, 'Reshape_2');
input_layer = imageInputLayer([1,1,4], 'name', 'Inputs', 'Normalization', 'none');
output_layer = regressionLayer('name', 'Output');
model = replaceLayer(model, 'Inputs', input_layer);
model = replaceLayer(model, 'RegressionLayer_Reshape_2', output_layer);
model = connectLayers(model, 'Inputs', 'bn');
model = connectLayers(model, 'Last_dense', 'Output');
model = assembleNetwork(model);
save('nn_model.mat', 'model')