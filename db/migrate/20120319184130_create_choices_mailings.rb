class CreateChoicesMailings < ActiveRecord::Migration
  def change
    create_table :choices_mailings, id: false do |t|
      t.integer :choice_id
      t.integer :mailing_id
    end

    add_index :choices_mailings, :choice_id
    add_index :choices_mailings, :mailing_id
  end
end
