<?php

use App\Http\Controllers\UserController;

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

// $router->get('/', function () use ($router) {
//     return $router->app->version();
// });

$router->get('/', function () {
    return response()->json([
        'message' => '🎉 User Service Hidup!',
        'service' => 'Ini adalah Dapur User',
        'status' => 'ready',
        'timestamp' => \Carbon\Carbon::now()->toDateTimeString(),
        'routes' => [
            'register' => 'POST /api/auth/register',
            'login' => 'POST /api/auth/login',
            'get_all_users' => 'GET /api/users',
            'get_user' => 'GET /api/users/{id}',
            'update_user' => 'PUT /api/users/{id}',
            'delete_user' => 'DELETE /api/users/{id}'
        ]
    ]);
});

$router->group(['prefix' => 'api/auth'], function () use ($router) {
    $router->post('/register', 'UserController@register');
    $router->post('/login', 'UserController@login');
    $router->post('/refresh', 'UserController@refresh');
});

$router->group(['prefix' => 'api/users', 'middleware' => 'jwt'], function() use ($router) {
    $router->get('/', 'UserController@index');
    $router->get('/{id}', 'UserController@show');
    $router->put('/{id}', 'UserController@update');
    $router->delete('/{id}', 'UserController@destroy');
});

$router->get('/{any:.*}', function () {
    return response()->json([
        'error' => 'Route tidak ditemukan',
        'message' => 'Cek dokumentasi routes yang tersedia',
        'available_routes' => [
            'GET /',
            'POST /api/auth/register',
            'POST /api/auth/login',
            'GET /api/users',
            'GET /api/users/{id}',
            'PUT /api/users/{id}',
            'DELETE /api/users/{id}'
        ]
    ], 404);
});
