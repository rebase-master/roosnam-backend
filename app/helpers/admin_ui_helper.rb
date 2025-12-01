module AdminUiHelper
  MODEL_ICON_MAP = {
    'User' => 'fa-user-circle',
    'WorkExperience' => 'fa-briefcase',
    'Education' => 'fa-graduation-cap',
    'Skill' => 'fa-lightbulb',
    'Certification' => 'fa-award',
    'ClientProject' => 'fa-diagram-project',
    'ClientReview' => 'fa-comments',
    'ActiveStorage::Blob' => 'fa-paperclip',
  }.freeze

  def admin_nav_sections
    visible_models = RailsAdmin::Config.visible_models(controller: controller)
    models_by_name = visible_models.index_by { |config| config.abstract_model.model_name }

    ordered_sections = [
      { label: 'Portfolio', models: %w[User WorkExperience Skill Education Certification ClientProject ClientReview] },
    ]

    used_models = []
    sections = ordered_sections.filter_map do |section|
      items = section[:models].filter_map do |name|
        config = models_by_name[name]
        next unless config

        used_models << name
        nav_item_hash(config)
      end
      next if items.empty?

      { label: section[:label], items: items }
    end

    leftovers = visible_models.reject do |config|
      used_models.include?(config.abstract_model.model_name)
    end

    if leftovers.any?
      sections << {
        label: 'Other',
        items: leftovers.map { |config| nav_item_hash(config) },
      }
    end

    sections
  end

  def admin_static_links
    RailsAdmin::Config.navigation_static_links.map do |title, url|
      { label: title, url: url }
    end
  end

  def admin_model_icon(model_name)
    MODEL_ICON_MAP[model_name.to_s] || 'fa-folder-tree'
  end

  def availability_badge(value)
    return '' if value.blank?

    tone =
      case value.to_s
      when 'available' then :primary
      when 'open_to_opportunities' then :accent
      when 'not_available' then :muted
      else :muted
      end

    status_badge(value.to_s.humanize, tone)
  end

  def rating_badge(value)
    return '' if value.blank?

    status_badge("#{value} ★", value.to_i >= 4 ? :primary : :accent)
  end

  def status_badge(label, tone = :primary)
    tone_class =
      {
        primary: 'badge-primary',
        accent: 'badge-accent',
        muted: 'badge-muted',
      }[tone] || 'badge-muted'

    content_tag(:span, label, class: "badge #{tone_class}")
  end

  private

  def nav_item_hash(config)
    abstract_model = config.abstract_model
    model_param = abstract_model.to_param

    {
      label: config.label_plural,
      path: rails_admin.url_for(action: :index, controller: 'rails_admin/main', model_name: model_param),
      icon: admin_model_icon(abstract_model.model_name),
      active: (@abstract_model&.to_param == model_param),
    }
  end
end

