# Copyright � 2012-2013 Harry Garrood
# This file is a part of redmine_release_notes.

# redmine_release_notes is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# redmine_release_notes is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with redmine_release_notes.  If not, see <http://www.gnu.org/licenses/>.

module RedmineReleaseNotes
  module IssuePatch
    def self.perform
      Issue.class_eval do
        has_one :release_note,
          :dependent => :destroy,
          :inverse_of => :issue

        validates_associated :release_note
        
        validate :cant_close_with_release_notes_todo,
          :if => :closed?

        def cant_close_with_release_notes_todo
          if release_note && release_note.status == 'todo'
            errors.add(:base,
              I18n.t('release_notes.cant_close_with_release_notes_todo'))
          end
        end

        # all the issues which need release notes (including ones which have
        # them already)
        def self.release_notes_required
          joins(:release_note).where('release_notes.status' => ['todo', 'done'])
        end

        # issues which still need release notes
        def self.release_notes_todo
          joins(:release_note).where('release_notes.status' => 'todo')
        end

        # issues whose release notes are done
        def self.release_notes_done
          joins(:release_note).where('release_notes.status' => 'done')
        end

        def release_notes_done?
          release_note.done?
        end
      end
    end
  end
end
