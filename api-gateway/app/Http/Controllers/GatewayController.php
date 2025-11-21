<?php

namespace App\Http\Controllers;

use Exception;
use GuzzleHttp\Client;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GatewayController extends Controller
{
    private $userServiceUrl = 'http://user-service:8001';
    private $todoServiceUrl = 'http://todo-service:8002';

    public function forwardToUserService(Request $request)
    {
        return $this->forwardRequest($request, $this->userServiceUrl);
    }

    public function forwardToTodoService(Request $request)
    {
        return $this->forwardRequest($request, $this->todoServiceUrl);
    }

    private function forwardRequest(Request $request, $serviceUrl)
    {
        try {
            $client = new Client();
            $targetUrl = $serviceUrl . $request->getRequestUri();

            $response = $client->request($request->method(),$targetUrl, [
                'headers' => $request->headers->all(),
                'json' => $request->all(),
                'timeout' => 30,
            ]);

            return response(
                $response->getBody(),
                $response->getStatusCode()
            )->withHeaders($response->getHeaders());
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Service tidak dapat dihubungi',
                'message' => $e->getMessage(),
                'service_url' => $serviceUrl,
            ], 503);
        }
    }
}
