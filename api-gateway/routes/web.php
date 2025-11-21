<?php

// use App\Http\Controllers\GatewayController;

/** @var \Laravel\Lumen\Routing\Router $router */

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It is a breeze. Simply tell Lumen the URIs it should respond to
| and give it the Closure to call when that URI is requested.
|
*/

$router->get('/', function () use ($router) {
    return response()->json([
        'message' => 'Api Gateway Hidup',
        'service' => 'Resepsionis Microservices',
        'routes' => [
            'users' => '/api/users/*',
            'todos' => '/api/todos/*',
            'auth' => '/api/auth/*',
        ],
    ]);
});

$router->group(['prefix' => 'api/users'], function () use ($router) {
    $router->get('/','GatewayController@forwardToUserService');
    $router->get('/{id}','GatewayController@forwardToUserService');
    $router->post('/','GatewayController@forwardToUserService');
    $router->put('/{id}','GatewayController@forwardToUserService');
    $router->delete('/{id}','GatewayController@forwardToUserService');
});

$router->group(['prefix' => 'api/auth'], function () use ($router) {
    $router->post('/login', 'GatewayController@forwardToUserService');
    $router->post('/register', 'GatewayController@forwardToUserService');
});

$router->group(['prefix' => 'api/todos'], function () use ($router) {
    $router->get('/', 'GatewayController@forwardToTodoService');
    $router->get('/{id}', 'GatewayController@forwardToTodoService');
    $router->post('/', 'GatewayController@forwardToTodoService');
    $router->put('/{id}', 'GatewayController@forwardToTodoService');
    $router->delete('/{id}', 'GatewayController@forwardToTodoService');
    $router->patch('/{id}/toggle', 'GatewayController@forwardToTodoService');
});

$router->get('/{any:.*}', function () {
    return response()->json([
        'error' => 'Route tidak ditemukan',
        'message' => 'Cek Dokumnetasi route yang tersedia',
    ], 404);
});


