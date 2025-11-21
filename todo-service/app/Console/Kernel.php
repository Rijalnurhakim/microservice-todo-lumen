<?php

namespace App\Console;

use Carbon\Carbon;
use App\Models\Todo;
use Illuminate\Console\Scheduling\Schedule;
use Laravel\Lumen\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * The Artisan commands provided by your application.
     *
     * @var array
     */
    protected $commands = [
        //
    ];

    /**
     * Define the application's command schedule.
     *
     * @param  \Illuminate\Console\Scheduling\Schedule  $schedule
     * @return void
     */
    protected function schedule(Schedule $schedule)
    {
        // $schedule->call(function () {
        //     Todo::where('completed', false)
        //         ->where('due_date', '<', Carbon::now ()->toDateTimeString())
        //         ->update(['status' => 'expired']);
        //     echo "Expired todos updated.\n";
        // })->daily();

        $schedule->call(function () {
            echo "[" . Carbon::now()->toDateTimeString() . "] Cron is working!\n";
        })->everyMinute();

        $schedule->call(function () {
            $total = Todo::count();
            $completed = Todo::where('completed', true)->count();
            $pending = $total - $completed;
            echo "[" . Carbon::now()->toDateTimeString() . "] Todon Stats -Total: {$total}, Completed: {$completed}, Pending: {$pending}\n";
        })->everyFiveMinutes();

        $schedule->call(function () {
            $reminderCount = Todo::where('completed', false)
                ->inRandomOrder()
                ->limit(2)
                ->update(['description' => 'Reminder: Complete this soon!']);
            echo "[" . Carbon::now()->toDateTimeString() . "] Sent reminders to {$reminderCount} todos\n";
        })->everyTenMinutes();
    }
}
