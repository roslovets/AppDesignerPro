p = AsyncWorker(0);
p.addRepeatedTask(@fun1, 0.1, 10);
p.addTask(@fun1);
% p.addDelayedTask(@(x)fun1(x), 1);
% p.addDelayedTask(@(x)fun1(x), 0);
p.addDelay(1);
% p.addTask(@(x)fun1(x));
% p.addTask(@(x)fun1(x));
% p.addTask(@(x)fun1(x));
% p.addDelayedTask(@(x)fun2(x), 1);
p.start();

function data = fun1(worker, data)
data = data + 1;
disp(data);
end

function data = fun2(worker, data)
data = data + 2;
disp(data);
end