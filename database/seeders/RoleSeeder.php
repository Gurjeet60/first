<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;

class RoleSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
   public function run(): void
        {
            Role::updateOrCreate(
                ['id' => 1],
                ['role_name' => 'Admin']
            );
        
            Role::updateOrCreate(
                ['id' => 2],
                ['role_name' => 'Customer']
            );
        }
    }


