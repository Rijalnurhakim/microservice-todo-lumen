<?php

namespace App\Http\Controllers;

use Exception;
use App\Models\Todo;
use Illuminate\Http\Request;

class TodoController extends Controller
{
    public function index()
    {
        try {
            $todos = Todo::all();
            return response()->json($todos);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal mengambil data todo',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            $todo = Todo::find($id);

            if (!$todo) {
                return response()->json(['error' => 'Todo tidak ditemukan'], 404);
            }

            return response()->json($todo);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal mengambil data todo',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            $this->validate($request, [
                'title' => 'required|string|max:255',
                'description'=> "nullable|string",
                'user_id' => 'required|integer',
            ]);

            $todo = Todo::create([
                'title' => $request->title,
                'description' => $request->description,
                'user_id' => $request->user_id,
                'completed' => false,
            ]);

            return response()->json([
                'message' => 'Todo berhasil dibuat',
                'data' => $todo,
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal membuat todo',
                'message' => $e->getMessage()
                ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        try {
            $todo = Todo::find($id);

            if (!$todo) {
                return response()->json(['error' => 'Todo tidak ditemukan'], 404);
            }

            $todo->update($request->all());

            return response()->json([
                'message' => 'Todo berhasil diperbarui',
                'todo' => $todo,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal memperbarui todo',
                'message' => $e->getMessage(),
                ], 500);
        }
    }

    public function destroy($id)
    {
        try {
            $todo =Todo::find($id);

            if (!$todo) {
                return response()->json([
                    'error' => 'Todo tidak ditemukan'
                ], 404);
            }

            $todo->delete();

            return response()->json([
                'message' => 'todo berhasil dihapus'
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal menghapus todo',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    public function toggle($id)
    {
        try {
            $todo = Todo::find($id);

            if (!$todo) {
                return response()->json(['error' => 'Todo tidak ditemukan'], 404);
            }

            $todo->update(['completed' => !$todo->completed]);

            return response()->json([
                'message' => 'Todo status berhasil diupdate',
                'todo' => $todo,
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Gagal update status todo',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}
