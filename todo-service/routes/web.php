<?php

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

$router->get('/', function () {
    return response()->json([
        'message' => 'Todo Service is running',
        'service' => 'Ini dapur todo',
        'status' => 'ready',
        'timestamp' => \Carbon\Carbon::now()->toDateTimeString(),
        'routes' => [
            'get_all_todos' => 'GET /api/todos',
            'get_todo' => 'GET /api/todos/{id}',
            'create_todo' => 'POST /api/todos',
            'update_todo' => 'PUT /api/todos/{id}',
            'delete_todo' => 'DELETE /api/todos/{id}',
            'toggle_todo' => 'PATCH /api/todos/{id}/toggle'
        ],
    ]);
});

$router->group(['prefix' => 'api/todos'], function () use ($router) {
    $router->get('/', 'TodoController@index');
    $router->get('/{id}', 'TodoController@show');
    $router->post('/', 'TodoController@store');
    $router->put('/{id}', 'TodoController@update');
    $router->delete('/{id}', 'TodoController@destroy');
    $router->patch('/{id}/toggle', 'TodoController@toggle');
});

$router->get('/{any:.*}', function() {
    return response()->json([
        'error' => 'Route tidak ditemukan',
        'message' => 'cek kembali dokumentasi API untuk rute yang benar'
    ], 404);
});
