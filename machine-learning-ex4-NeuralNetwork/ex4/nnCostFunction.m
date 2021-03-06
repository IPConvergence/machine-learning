function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices.
%
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);

% You need to return the following variables correctly
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

a1 = [ones(size(X,1),1),X]; %5000 * 401
z2 = a1 * Theta1'; %5000 * 25
a2 = sigmoid(z2); %5000 * 25
a2 = [ones(size(a2,1),1),a2]; % 5000 * 26
z3 = a2 * Theta2'; % 5000 * 10
a3 = sigmoid(z3); % 5000 * 10

Y= zeros(m, num_labels); % 5000 * 10
% ! I made a big issue with generation of Y, check well here under because I use something smaller but I had issue of matrix size
for k = 1:num_labels
    Y(:,k) = y == k;
end

J= -1/m * sum(sum(Y.*log(a3) + (1-Y).*log(1-a3)));

% Include the regularisation parameters in the calculation
theta1=Theta1(:,2:size(Theta1,2)); % 25*400
theta2=Theta2(:,2:size(Theta2,2)); % 10*25
J= J+ lambda /(2* m) * (sum(sum(theta1.^2))+ sum(sum(theta2.^2)));
% -------------------------------------------------------------

% =========================================================================
% backpropagation calculation

delta1=0;
delta2=0;

for t=1:m
  %step1
    at1=a1(t,:)'; %401*1
    zt2=Theta1 * at1; % 25*401 * 401*1 = 25*1
    at2=sigmoid(zt2); % 25*1
    at2=[1; at2]; % 26 *1
    zt3= at2 * Theta2'; % 1*26   * 26*10 = 1 *10
    a3t=sigmoid(zt3); % 1*10

  %step2
    lambda3t=at3 - Y(t,:); % 1*10

  %step3
  templambbda2t=Theta2' * lambda3t'; % 26*10 * 10*1 = 26*1
  lambda2t= templambbda2t(:,2:size(templambbda2t,1)).*sigmoidGradient(zt2')  ; % we reduce to 25*1
  %step4
  delta2=delta2 + lambda3t' * at2';  %10*1 * 1*26 -> 10 * 26
  delta2=delta2(:,2:size(delta2,2)); % 10*25
  delta1=delta1+ lambda2t'*at1'; %25*1 * 1*401 -> 25*401
  delta1=delta1(:,2:size(delta1,2)); % 25*401
end

  Theta1_grad=delta1/m ;
  Theta2_grad=delta2/m;

% Unroll gradients
  grad = [Theta1_grad(:) ; Theta2_grad(:)];
end
