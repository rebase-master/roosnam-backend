module Admin
  class Metrics
    RECENT_MODELS = [
      WorkExperience,
      ClientProject,
      ClientReview,
      Education,
      Certification,
      Skill,
    ].freeze

    def stat_cards
      [
        { label: 'Experiences', value: WorkExperience.count, icon: 'fa-briefcase', caption: 'Timeline entries' },
        { label: 'Skills', value: Skill.count, icon: 'fa-lightbulb', caption: 'Catalogued proficiencies' },
        { label: 'Client Projects', value: ClientProject.count, icon: 'fa-diagram-project', caption: 'Shipped case studies' },
        { label: 'Testimonials', value: ClientReview.count, icon: 'fa-comments', caption: 'Client feedback' },
      ]
    end

    def recent_updates(limit: 6)
      RECENT_MODELS.flat_map do |model|
        model.order(updated_at: :desc).limit(limit).map do |record|
          {
            model: model,
            record: record,
            label: record_label(model, record),
            updated_at: record.updated_at,
          }
        end
      end.sort_by { |entry| entry[:updated_at] }.reverse.first(limit)
    end

    def weekly_activity
      {
        'Work Experience' => WorkExperience.group_by_week(:created_at, last: 8, current: true).count,
        'Client Projects' => ClientProject.group_by_week(:created_at, last: 8, current: true).count,
      }
    end

    def skill_mix
      Skill.group(:proficiency_level)
          .count
          .transform_keys { |key| key.present? ? key.to_s.humanize : 'Unspecified' }
    end

    private

    def record_label(model, record)
      record.try(:name) ||
        record.try(:title) ||
        record.try(:reviewer_name) ||
        record.try(:full_name) ||
        "#{model.model_name.human} ##{record.id}"
    end
  end
end

