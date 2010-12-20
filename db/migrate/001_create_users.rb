class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :nickname, :string, :limit => 100, :null => false
      t.column :forename, :string
      t.column :surname, :string
      t.column :email, :string, :null => false
      t.column :password, :string, :limit => 32, :null => false
      t.column :date_of_birth, :date
      t.column :gender, :string, :limit => 1
      t.column :description, :text
      t.column :subscribe, :boolean
      t.column :activation_code, :string
      t.column :activation_date, :datetime
      t.column :admin, :int, :limit => 1
      t.column :subscribe, :int, :limit => 1
      t.column :updated_on, :datetime
      t.column :created_on, :datetime
    end

    add_index :users, :activation_code
    add_index :users, :nickname
    add_index :users, :email

    User.create :nickname => 'Anonymous', :email => 'noreply@musicknows.com', :password => '5f4dcc3b5aa765d61d8327deb882cf99'
    User.create :nickname => 'duncan', :forename => 'Duncan', :surname => 'Gough', :email => 'duncan@suttree.com', :date_of_birth => '1975-02-23', :password => '08552d48aa6d6d9c05dd67f1b4ba8747', :subscribe => 1, :admin => 1
    User.create :nickname => 'jane', :forename => 'Jane', :surname => 'Gough', :email => 'jane@suttree.com', :date_of_birth => '1973-06-18', :password => '08552d48aa6d6d9c05dd67f1b4ba8747', :subscribe => 1, :admin => 1
  end

  def self.down
    drop_table :users
  end
end
